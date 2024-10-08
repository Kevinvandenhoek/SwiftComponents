//
//  AnimatedBall.swift
//  SwiftComponents
//
//  Created by Kevin van den Hoek on 01/10/2024.
//

import SwiftUI

struct AnimatedBall: View {
    
    @State var isUp: Bool = true
    
    var body: some View {
        VStack {
            if isUp {
                Spacer()
            }
            
            Circle()
                .id("ball")
                .onTapGesture {
                    isUp.toggle()
                }
            
            if !isUp {
                Spacer()
            }
        }
    }
}

#Preview {
    AnimatedBall()
}
