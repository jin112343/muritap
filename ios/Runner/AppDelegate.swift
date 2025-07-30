import Flutter
import UIKit
import GameKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // GameCenter MethodChannel設定
    let controller = window?.rootViewController as! FlutterViewController
    let gameCenterChannel = FlutterMethodChannel(
      name: "game_center_channel",
      binaryMessenger: controller.binaryMessenger
    )
    
    gameCenterChannel.setMethodCallHandler { [weak self] (call, result) in
      self?.handleGameCenterMethod(call: call, result: result)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleGameCenterMethod(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "signInToGameCenter":
      authenticatePlayer(result: result)
      
    case "submitScore":
      if let args = call.arguments as? [String: Any],
         let leaderboardId = args["leaderboardId"] as? String,
         let score = args["score"] as? Int {
        submitScore(leaderboardId: leaderboardId, score: score, result: result)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      }
      
    case "showLeaderboard":
      if let args = call.arguments as? [String: Any],
         let leaderboardId = args["leaderboardId"] as? String {
        showLeaderboard(leaderboardId: leaderboardId, result: result)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      }
      
    case "openGameCenterSettings":
      openGameCenterSettings(result: result)
      
    case "getCurrentPlayerScore":
      if let args = call.arguments as? [String: Any],
         let leaderboardId = args["leaderboardId"] as? String {
        getCurrentPlayerScore(leaderboardId: leaderboardId, result: result)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      }
      
    case "getLeaderboardEntries":
      if let args = call.arguments as? [String: Any],
         let leaderboardId = args["leaderboardId"] as? String {
        getLeaderboardEntries(leaderboardId: leaderboardId, result: result)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func authenticatePlayer(result: @escaping FlutterResult) {
    GKLocalPlayer.local.authenticateHandler = { viewController, error in
      if let viewController = viewController {
        // 認証画面を表示
        DispatchQueue.main.async {
          let rootViewController = self.getRootViewController()
          rootViewController?.present(viewController, animated: true)
        }
      } else if error != nil {
        // エラー
        result(false)
      } else {
        // 認証成功
        result(true)
      }
    }
  }
  
  private func submitScore(leaderboardId: String, score: Int, result: @escaping FlutterResult) {
    print("Submitting score: \(score) to leaderboard: \(leaderboardId)")
    
    // 古いAPIを使用（より安定している）
    let scoreReporter = GKScore(leaderboardIdentifier: leaderboardId)
    scoreReporter.value = Int64(score)
    
    GKScore.report([scoreReporter]) { error in
      DispatchQueue.main.async {
        if let error = error {
          print("Error submitting score: \(error.localizedDescription)")
          result(false)
        } else {
          print("Score submitted successfully: \(score)")
          result(true)
        }
      }
    }
  }
  
  private func showLeaderboard(leaderboardId: String, result: @escaping FlutterResult) {
    let viewController = GKGameCenterViewController()
    viewController.gameCenterDelegate = self
    viewController.viewState = .leaderboards
    viewController.leaderboardIdentifier = leaderboardId
    
    DispatchQueue.main.async {
      let rootViewController = self.getRootViewController()
      rootViewController?.present(viewController, animated: true)
    }
    result(nil)
  }
  
  private func openGameCenterSettings(result: @escaping FlutterResult) {
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(settingsUrl)
    }
    result(nil)
  }
  
  private func getCurrentPlayerScore(leaderboardId: String, result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      // iOS 14.0以降のAPIを使用
      GKLeaderboard.loadLeaderboards(IDs: [leaderboardId]) { leaderboards, error in
        if let error = error {
          print("Error loading leaderboard: \(error.localizedDescription)")
          result(nil)
          return
        }
        
        guard let leaderboard = leaderboards?.first else {
          result(nil)
          return
        }
        
        leaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: .allTime) { localPlayerEntry, entries, error in
          DispatchQueue.main.async {
            if let error = error {
              print("Error loading entries: \(error.localizedDescription)")
              result(nil)
            } else if let entry = localPlayerEntry {
              result(entry.score)
            } else {
              result(nil)
            }
          }
        }
      }
    } else {
      // iOS 14.0未満の場合は古いAPIを使用
      let leaderboard = GKLeaderboard()
      leaderboard.identifier = leaderboardId
      leaderboard.loadScores { scores, error in
        DispatchQueue.main.async {
          if let error = error {
            print("Error loading scores: \(error.localizedDescription)")
            result(nil)
          } else if let scores = scores {
            // ローカルプレイヤーのスコアを探す
            for score in scores {
              if score.player == GKLocalPlayer.local {
                result(score.value)
                return
              }
            }
            result(nil)
          } else {
            result(nil)
          }
        }
      }
    }
  }
  
  private func getLeaderboardEntries(leaderboardId: String, result: @escaping FlutterResult) {
    print("Loading leaderboard entries for: \(leaderboardId)")
    
    // 古いAPIを使用（より安定している）
    let leaderboard = GKLeaderboard()
    leaderboard.identifier = leaderboardId
    leaderboard.loadScores { scores, error in
      DispatchQueue.main.async {
        if let error = error {
          print("Error loading scores: \(error.localizedDescription)")
          result([])
        } else if let scores = scores {
          print("Loaded \(scores.count) scores from leaderboard")
          
          var leaderboardEntries: [[String: Any]] = []
          
          for score in scores {
            leaderboardEntries.append([
              "playerName": score.player.displayName,
              "score": score.value,
              "rank": 0, // 一時的に0に設定
              "isCurrentPlayer": score.player == GKLocalPlayer.local
            ])
          }
          
          // スコアでソート（高いスコアが上位）
          leaderboardEntries.sort { ($0["score"] as? Int ?? 0) > ($1["score"] as? Int ?? 0) }
          
          // ランクを再計算
          for (index, entry) in leaderboardEntries.enumerated() {
            leaderboardEntries[index]["rank"] = index + 1
          }
          
          print("Sorted leaderboard entries: \(leaderboardEntries.map { "\($0["playerName"]): \($0["score"])" })")
          result(leaderboardEntries)
        } else {
          print("No scores found in leaderboard")
          result([])
        }
      }
    }
  }
  
  // iOS 11.0以降で互換性のあるrootViewController取得メソッド
  private func getRootViewController() -> UIViewController? {
    if #available(iOS 13.0, *) {
      // iOS 13.0以降の方式
      return UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first?.windows
        .first(where: { $0.isKeyWindow })?.rootViewController
    } else {
      // iOS 13.0未満の方式
      return UIApplication.shared.keyWindow?.rootViewController
    }
  }
}

// MARK: - GKGameCenterControllerDelegate
extension AppDelegate: GKGameCenterControllerDelegate {
  func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismiss(animated: true)
  }
}
