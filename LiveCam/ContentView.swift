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
        VStack(spacing: 20) {
            if let cameraData = viewModel.cameraData {
                // 地点名
                Text(cameraData.place)
                    .font(.title3)
                    .fontWeight(.bold)
                if let latestTime = viewModel.latestTime, let image = viewModel.images[latestTime] {
                    // 画像の時刻
                    Text(viewModel.dateText(latestTime))
                        .fontWeight(.bold)
                    // 画像
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("画像読み込み中...")
                }
            } else {
                Text("読み込み中...")
            }
        }
        .padding(20)
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
