//
//  ContentView.swift
//  Shared
//
//  Created by Tomohiro Tashiro on 2022/05/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LiveCamViewModel()
    
    var body: some View {
        if let cameraData = viewModel.cameraData {
            VStack {
                Text(cameraData.place)
                if let latestTime = viewModel.latestTime, let image = viewModel.images[latestTime] {
                    Text(viewModel.dateText(latestTime))
                    Image(uiImage: image)
                } else {
                    Text("Image loading...")
                }
            }
        } else {
            Text("Loading...")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
