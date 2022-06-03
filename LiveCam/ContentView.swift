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
                if let currentTime = viewModel.currentTime, let image = viewModel.images[currentTime] {
                    HStack(spacing: 10) {
                        // 画像の時刻
                        Text(viewModel.dateText(currentTime))
                            .fontWeight(.bold)
                            .frame(width: 160)

                        // 再生・停止ボタン
                        Button(action: {
                            viewModel.toggleTimer()
                        }, label: {
                            if viewModel.isAnimating {
                                Image(systemName: "pause.fill")
                            } else {
                                Image(systemName: "play.fill")
                            }
                        })
                        .padding(5)
                        .background(Color.white)
                        .cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.blue, lineWidth: 1))
                    }

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
