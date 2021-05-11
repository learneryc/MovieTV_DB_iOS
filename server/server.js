var express = require('express');
const path = require('path');
var app = express();
var axios = require('axios');
const cors = require('cors');

const api_key = 'api_key=4e3c06c4f9ca541c9e94a0b488f30b2b';
const host = 'https://api.themoviedb.org/3/';
const img_path = 'https://image.tmdb.org/t/p/w500';
const avatar_path = 'https://image.tmdb.org/t/p/original';
const backdrop_placeholder = 'N/A';
const poster_placeholder = 'N/A';
const video_placeholder = 'tzkWB85ULJY';
const avatar_placeholder = 'assets/img/avatar.jpeg';
const website = {'imdb_id': 'imdb.com/name/', 'facebook_id': 'facebook.com/',
				'instagram_id': 'instagram.com/', 'twitter_id': 'twitter.com/'
}

const urls = {'search': `${host}search/multi?${api_key}&language=en-US&query=`,
	'trending': [`${host}trending/`, `/day?${api_key}`],
	'top': [host, `/top_rated/?${api_key}&language=en-US&page=1`],
	'nowPlaying': [host, `/now_playing?${api_key}&language=en-US&page=1`],
	'popular': [host, `/popular?${api_key}&language=en-US&page=1`],
	'recommend': [host, `/recommendations?${api_key}&language=en-US&page=1`],
	'similar': [host, `/similar?${api_key}&language=en-US&page=1`],
	'video': [host, `/videos?${api_key}&language=en-US&page=1`],
	'detail': [host, `?${api_key}&language=en-US&page=1`],
	'review': [host, `/reviews?${api_key}&language=en-US&page=1`],
	'cast': [host, `/credits?${api_key}&language=en-US&page=1`],
	'castDetail': [host, `?${api_key}&language=en-US&page=1`],
	'castEx': [host, `/external_ids?${api_key}&language=en-US&page=1`]
	};

const fields = {'search':['id', 'name', 'backdrop_path', 'poster_path', 'media_type', 'vote_average', 'release_date'],
	'trending':['id', 'name', 'poster_path', 'release_date'],
	'top': ['id', 'name', 'poster_path', 'release_date'],
	'nowPlaying': ['id', 'name', 'poster_path', 'release_date'],
	'popular': ['id', 'name', 'poster_path', 'release_date'],
	'recommend': ['id', 'name', 'poster_path'],
	'similar': ['id', 'name', 'poster_path'],
	'video': ['site', 'type', 'name', 'key'],
	'detail': ['name', 'genres', 'spoken_languages', 'release_date',
			'runtime', 'overview', 'vote_average', 'tagline', 'poster_path'],
	'review': ['author', 'content', 'created_at', 'url', 'rating', 'avatar_path'],
	'cast': ['id', 'name', 'character', 'profile_path'],
	'castDetail': ['birthday', 'gender', 'name', 'homepage', 'place_of_birth',
			'also_known_as', 'known_for_department', 'biography', 'profile_path'],
	'castEx': ['imdb_id', 'facebook_id', 'instagram_id', 'twitter_id']
	};

//cors
app.use(cors());

app.get('/api/:type/:api', function(req, res) {
	let type = req.params.type;
	let api = req.params.api;
	let url = urls[api][0]+type+urls[api][1];

	axios.get(url).then(response=>{
		let results = extractFields(response.data.results, api);
		res.json({'results':results});
	});
})

app.get('/api/:type/:api/:id', function(req, res) {
	let type = req.params.type;
	let api = req.params.api;
	let id = req.params.id;
	let url = `${urls[api][0]}${type}/${id}${urls[api][1]}`;

	axios.get(url).then(response=>{
		let results=[];
		if (api =='detail') results=extractFromOne(response.data, api);
		else if (api=='cast') results=extractFields(response.data.cast, api);
		else if (api=='castDetail') results=extractFromOne(response.data, api);
		else if (api=='castEx') results=extractEx(response.data, api);
		else if (api=='video') results=extractVideo(response.data, api);
		else results = extractFields(response.data.results, api);
		res.json({'results':results});
	});
})

app.get('/search/*', function(req, res) {
	let url = urls['search']+req.params[0];

	axios.get(url).then(response=> {
		let results = filterSearch(response.data.results, 'search');
		res.json({'results':results});
	});
})

function filterSearch(res, api) {
	let results=[];
	res.forEach( r => {
		if (r.media_type=='tv' || r.media_type=='movie')
			results.push(extractFromOne(r, api));
	});
	return results;
}

function extractFields(res, api) {
	let results=[];

	res.forEach( r => {
		results.push(extractFromOne(r, api));
	})
	return results;
}

function extractFromOne(res, api) {
	let field = fields[api];
	let results = {};

	if (!('name' in res)) res['name']=res['title'];
	if (!('release_date' in res)) res['release_date']=res['first_air_date'];
	if (!('runtime' in res)) res['runtime']=res['episode_run_time'];
	if ('author_details' in res) {
		res['rating'] = res['author_details'].rating;
		res['avatar_path'] = res['author_details'].avatar_path;

		if (!res['avatar_path'])
			res['avatar_path'] = avatar_placeholder;
		else if (res['avatar_path'].indexOf('/http:')==0 || res['avatar_path'].indexOf('/https:')==0)
			res['avatar_path'] = res['avatar_path'].substring(1);
		else
			res['avatar_path'] = avatar_path + res['avatar_path'];
	}
	if ('profile_path' in res && res['profile_path'])
		res['profile_path'] = img_path+res['profile_path'];

	field.forEach((f)=>{
		results[f] = res[f];
		if (f=='backdrop_path')
			results[f] = results[f]?img_path+results[f]:backdrop_placeholder;
		else if (f=='poster_path')
			results[f] = results[f]?img_path+results[f]:poster_placeholder;
		if (!results[f]) results[f] = 'N/A';
	});
	return results;
}

function extractVideo(res, api) {
	let field = fields[api];
	let results = {"id": video_placeholder};
	res = res["results"];

	for (let r of res) {
		console.log(r["key"])
		if (r["type"] == "Teaser") {
			results["id"] = r["key"];
			break;
		} else if (r["type"] == "Trailer" && results["id"]==video_placeholder) {
			results["id"] = r["key"];
		}
	}
	return results;
}

function extractEx(res, api) {
	let field = fields[api];
	let results = {};
	field.forEach((f)=>{
		results[f] = res[f]? 'https://'+website[f]+res[f]:'N/A';
	})
	return results;
}

//listen on port 8080
app.listen(8080, function() {
    console.log("Server is listening at http://localhost:8080")
});