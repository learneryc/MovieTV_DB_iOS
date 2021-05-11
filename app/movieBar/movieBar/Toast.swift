//
//  Toast.swift
//  movieBar
//

import SwiftUI

struct Toast<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    let text: Text

    var body: some View {
        GeometryReader { geometry in

                    ZStack(alignment: .bottom) {

                        self.presenting()
                        ZStack {
                            VStack {
                                self.text.foregroundColor(.white).multilineTextAlignment(.center)
                            }
                            .frame(width: geometry.size.width / 1.3,
                                   height: geometry.size.height / 9)
                            .background(Color.gray)
                            .cornerRadius(100)
                            .opacity(self.isShowing ? 1 : 0)
                        }.padding(.bottom)
                        
                    }

                }
    }
}
