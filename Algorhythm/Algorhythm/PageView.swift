//
//  PageView.swift
//  Algorhythm
//
//  Created by Dan Bellini on 3/4/21.
//

import Foundation
import SwiftUI


struct PageView<Page: View>: View {
    
    var pages: [Page]

    var body: some View {
        PageViewController(pages: pages)
    }

}
