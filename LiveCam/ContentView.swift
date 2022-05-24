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
        VStack {
            if let cameraData = viewModel.cameraData {
                Text(cameraData.place)
                if let latestTime = viewModel.latestTime, let image = viewModel.images[latestTime] {
                    Text(viewModel.dateText(latestTime))
                    Image(uiImage: image)
                } else {
                    Text("画像読み込み中...")
                }
            } else {
                Text("読み込み中...")
            }
        }
        .alert(isPresented: $viewModel.hasError) {
            // エラー時にはAlertを表示する
            Alert(title: Text("データが読み込めませんでした。"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
