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

                // 画像下の表
                 VStack(spacing: 0) {
                     Label(key: " 場　所：", value: cameraData.place)
                         .background(Color(white: 0.95))
                     HStack {
                         Label(key: " 気　温：", value: String(cameraData.temperature.value) + cameraData.temperature.unit)
                             .background(Color.white)
                         Label(key: " 降水量：", value: String(cameraData.precipitation.value) + cameraData.precipitation.unit)
                             .background(Color.white)
                     }
                     HStack {
                         Label(key: " 風　向：", value: cameraData.windDirectionString)
                             .background(Color.white)
                         Label(key: " 風　速：", value: String(cameraData.wind.value) + cameraData.wind.unit)
                             .background(Color.white)
                     }
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

struct Label: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
                .foregroundColor(Color.blue)
            Text(value)
                .foregroundColor(Color.black)
            Spacer()
        }
        .frame(maxHeight: 30)
        .border(Color.gray)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
