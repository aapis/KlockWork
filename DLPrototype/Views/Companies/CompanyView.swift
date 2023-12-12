//
//  CompanyView.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-07-22.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyView: View {
    public var company: Company
     
    var body: some View {
        VStack{}
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("HI")
                    Spacer()
                }
            }
            .padding()
        }
        .background(Theme.toolbarColour)
        .onAppear(perform: actionOnAppear)
    }
}

extension CompanyView {
    private func actionOnAppear() -> Void {
    }
}

//struct CompanyView_Previews: PreviewProvider {
//    static var previews: some View {
//        CompanyView()
//    }
//}
