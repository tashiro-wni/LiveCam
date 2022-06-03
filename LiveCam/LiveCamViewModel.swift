//
//  LiveCamViewModel.swift
//  LiveCam
//
//  Created by Tomohiro Tashiro on 2022/05/23.
//

import Foundation
import UIKit

@MainActor
final class LiveCamViewModel: ObservableObject {
    @Published private(set) var cameraData: LiveCamData.Camera?
    private(set) var images: [String: UIImage] = [:]
    @Published private(set) var index = 0
    @Published private(set) var isAnimating = false
    @Published var hasError = false

    private var timer: Timer?
    private let urlString = "https://weathernews.jp/ip/livecam_json.cgi?pno=410000116"

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日(E) H:mm"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "JST")
        return dateFormatter
    }()

    var currentTime: String? {
        guard !images.isEmpty, index < images.count else { return nil }
        return images.keys.sorted(by: <)[index]
    }

    func dateText(_ key: String) -> String {
        guard let time = Double(key) else { return "" }
        return dateFormatter.string(from: Date(timeIntervalSince1970: time))
    }

    init() {
        load()
    }

    // アニメーションの開始・停止
    func toggleTimer() {
        if timer != nil {
            isAnimating = false
            timer?.invalidate()
            timer = nil
        } else {
            isAnimating = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
                guard let self = self, !self.images.isEmpty else { return }
                self.index = (self.index + 1) % self.images.count
            }
        }
    }

    private func load() {
        Task {
            do {
                // json 読み込み
                let camData = try await loadJson(urlString: urlString)
                cameraData = camData

                // 画像読み込み
                for item in camData.live_photo {
                    let image = try await loadImage(url: item.url)
                    images[item.time] = image
                }

                // アニメーション開始
                toggleTimer()
            } catch {
                hasError = true
            }
        }
    }

    private func loadJson(urlString: String) async throws -> LiveCamData.Camera {
        guard let url = URL(string: urlString) else { throw LoadError.wrongUrl }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let camData = try? JSONDecoder().decode(LiveCamData.self, from: data) else {
            throw LoadError.parseError
        }
        return camData.cam
    }

    private func loadImage(url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw LoadError.parseError
        }
        return image
    }
}

enum LoadError: Error {
    case wrongUrl
    case httpError
    case parseError
}

struct LiveCamData: Decodable {
    let cam: Camera

    struct Camera: Decodable {
        let place: String  // カメラ名
        let precipitation: ObsData  // 降水量
        let temperature: ObsData    // 気温
        let wind: ObsData           // 風向・風速
        let live_photo: [Photo]     // 時刻ごとの画像

        struct ObsData: Decodable {
            let value: Double
            let unit: String
            let direction: Int?  // 風向(16方位)
        }

        struct Photo: Decodable {
            let url: URL      // 画像URL
            let time: String  // 画像時刻 (unix_time)
        }

        var windDirectionString: String {
            let list = [ "無風", "北北東", "北東", "東北東", "東", "東南東", "南東", "南南東", "南",
                         "南南西", "南西", "西南西", "西", "西北西", "北西", "北北西", "北" ]
            guard let dir = wind.direction, dir >= 0, dir < list.count else { return "" }
            return list[dir]
        }
    }
}
