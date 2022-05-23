//
//  LiveCamViewModel.swift
//  LiveCam
//
//  Created by Tomohiro Tashiro on 2022/05/23.
//

import Foundation
import UIKit

final class LiveCamViewModel: ObservableObject {
    @Published private(set) var cameraData: LiveCamData.Camera?
    @Published private(set) var images: [String: UIImage] = [:]
    @Published var hasError = false

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "JST")
        return dateFormatter
    }()

    var latestTime: String? {
        images.keys.sorted(by: >).first
    }

    func dateText(_ key: String) -> String {
        guard let time = Double(key) else { return "" }
        return dateFormatter.string(from: Date(timeIntervalSince1970: time))
    }

    init() {
        Task {
            do {
                // json 読み込み
                let camData = try await loadJson()
                DispatchQueue.main.async { [weak self] in
                    self?.cameraData = camData
                }

                // 画像読み込み
                for item in camData.live_photo {
                    let image = try await loadImage(url: item.url)
                    DispatchQueue.main.async { [weak self] in
                        self?.images[item.time] = image
                    }
                }
            } catch {
                hasError = true
            }
        }
    }

    func loadJson() async throws -> LiveCamData.Camera {
        let urlString = "https://weathernews.jp/ip/livecam_json.cgi?pno=410000116"
        guard let url = URL(string: urlString) else { throw LoadError.wrongUrl }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let camData = try? JSONDecoder().decode(LiveCamData.self, from: data) else {
            throw LoadError.parseError
        }
        return camData.cam
    }

    func loadImage(url: URL) async throws -> UIImage {
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
        let photo: URL
        let place: String  // カメラ名
        let precipitation: ObsData  // 降水量
        let temperature: ObsData    // 気温
        let wind: ObsData           // 風向・風速
        let live_photo: [Photo]     // 時刻ごとの画像

        struct ObsData: Decodable {
            let value: Double
            let unit: String
            let direction: Int?
        }

        struct Photo: Decodable {
            let url: URL
            let time: String
        }
    }
}
