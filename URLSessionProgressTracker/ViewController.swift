//
//  ViewController.swift
//  URLSessionProgressTracker
//
//  Created by yilmaz on 26.09.2022.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    lazy var percentageLabel: UILabel = {
        let view = UILabel()
        view.text = "0%"
        view.font = .systemFont(ofSize: 30)
        return view
    }()
    
    lazy var startButton: UIButton = {
        
        var configuration = UIButton.Configuration.tinted()
        configuration.cornerStyle = .large
        configuration.baseForegroundColor = UIColor.systemPink
        configuration.buttonSize = .large
        configuration.subtitle = "to download video"
        configuration.title = "Press"

        let view = UIButton(configuration: configuration, primaryAction: nil)
        return view
    }()
    
    lazy var playerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var player: AVPlayer = {
        let ply = AVPlayer()
        return ply
    }()
    
    lazy var playerViewController: AVPlayerViewController = {
        let cnt = AVPlayerViewController()
        cnt.player = player
        return cnt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerViewController.view.frame = playerView.bounds
    }
    
    private func setupLayout() {
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        view.addSubview(percentageLabel)
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 30).isActive = true
        percentageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: 30).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        playerView.addSubview(playerViewController.view)
    }
    
    // MARK: event handler
    @objc func startButtonTapped() {
        let url = "https://dms.licdn.com/playlist/C4D05AQFpIWdkGLlTiA/mp4-720p-30fp-crf28/0/1663945351035?e=1664748000&v=beta&t=hFhwK6OZCCx_2FVroNSSdBRsQPJyVuDgjzUGduz0i1E"
        
        if let url = URL(string: url) {
            download(from: url)
        }
    }
    
    // MARK: download image from url
    func download(from url: URL) {
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
}

extension ViewController: URLSessionDownloadDelegate {
    // MARK: protocol stub for download completion tracking
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download finished: \(location)")
        do {
            let downloadedData = try Data(contentsOf: location)
            
            DispatchQueue.main.async(execute: {
                print("transfer completion OK!")
                
                let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
                let destinationPath = documentDirectoryPath.appendingPathComponent("video.mp4")
                
                let pdfFileURL = URL(fileURLWithPath: destinationPath)
                FileManager.default.createFile(atPath: pdfFileURL.path,
                                               contents: downloadedData,
                                               attributes: nil)
                
                if FileManager.default.fileExists(atPath: pdfFileURL.path) {
                    print("pdfFileURL present!") // Confirm that the file is here!
                    
                    print("Downloaded Data: \(pdfFileURL.path)")
                    self.player.replaceCurrentItem(with: AVPlayerItem(url: pdfFileURL))
                    self.player.automaticallyWaitsToMinimizeStalling = false
                }
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(progress * 100)".components(separatedBy: ".")[0] + "%"
        }
    }
}
