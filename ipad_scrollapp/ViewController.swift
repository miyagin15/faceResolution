//
//  ViewController.swift
//  test2
//
//  Created by ginga-miyata on 2019/08/02.
//  Copyright © 2019 ginga-miyata. All rights reserved.
//

import ARKit
import AudioToolbox
import Foundation
import Network
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var myCollectionView: UICollectionView!

    var changeNum = 0
    var callibrationUseBool = true

    var inputMethodString = "position"

    // 顔を認識できている描画するView
    @IBOutlet var tracking: UIView!

    @IBOutlet var inputClutchView: UIView!

    @IBOutlet var goalLabel: UILabel!
    @IBAction func timeCount(_: Any) {}

    @IBOutlet var timeCount: UISlider!
    @IBOutlet var functionalExpression: UISlider!

    @IBOutlet var sceneView: ARSCNView!
    // スクロール量を調整するSlider
    var ratioChange: Float = 5.0
    @IBAction func ratioChanger(_ sender: UISlider) {
        ratioChange = sender.value * 10
    }

    @IBOutlet var buttonLabel: UIButton!
    @IBAction func changeUseFace(_: Any) {
        changeNum = changeNum + 1
        i = 0
        time = 0
        goalLabel.text = String(resolutionPositionInt[i])
    }

    // 下を向いている度合いを示す
    @IBOutlet var orietationLabel: UILabel!
    @IBAction func toConfig(_: Any) {
        let secondViewController = storyboard?.instantiateViewController(withIdentifier: "CalibrationViewController") as! CalibrationViewController
        secondViewController.modalPresentationStyle = .fullScreen
        present(secondViewController, animated: true, completion: nil)
    }

    @IBAction func sendFile(_: Any) {
        // createFile(fileArrData: tapData)
        createCSV(fileArrData: nowgoal_Data)
    }

    @IBOutlet var functionalExpressionLabel: UILabel!
    @IBOutlet var callibrationBoolLabel: UIButton!
    @IBAction func callibrationConfigChange(_: Any) {
        if callibrationUseBool == false {
            callibrationUseBool = true
            callibrationBoolLabel.setTitle("キャリブレーション使う", for: .normal)
            return
        } else {
            callibrationUseBool = false
            callibrationBoolLabel.setTitle("キャリブレーション使わない", for: .normal)
            return
        }
    }

    @IBOutlet var inputMethodLabel: UIButton!
    @IBAction func inputMethodChange(_: Any) {
        if inputMethodString == "velocity" {
            inputMethodString = "position"
            inputMethodLabel.setTitle("position", for: .normal)
            return
//        } else if inputMethodString == "position" {
//            inputMethodString = "p_mouse"
//            inputMethodLabel.setTitle("p_mouse", for: .normal)
//            return
        } else if inputMethodString == "position" {
            inputMethodString = "velocity"
            inputMethodLabel.setTitle("velocity", for: .normal)
            return
        }
    }

    @IBOutlet var handsSlider: UISlider!
    // 値を端末に保存するために宣言
    let userDefaults = UserDefaults.standard
    @IBAction func deleteData(_: Any) {
        nowgoal_Data = []
        i = 0
        time = 0
        goalLabel.text = String(resolutionPositionInt[i])
        myCollectionView.contentOffset.x = firstStartPosition
        userDefaults.set(myCollectionView.contentOffset.x, forKey: "nowCollectionViewPosition")
        dataAppendBool = true
    }

    @IBOutlet var faceResoultionMemoryView: UIView!
    @IBAction func startButton(_: Any) {
        // nowgoal_Data = []
        i = 0
        time = 0
        goalLabel.text = String(resolutionPositionInt[i])
        // myCollectionView.contentOffset.x = firstStartPosition
        // userDefaults.set(myCollectionView.contentOffset.x, forKey: "nowCollectionViewPosition")
        dataAppendBool = true
//        let ratio = userDefaults.float(forKey: "ratio")
//        nowgoal_Data.append(Float(myCollectionViewPosition + 25))
//        nowgoal_Data.append(Float(ratio))
//        AudioServicesPlaySystemSound(sound)
//        let pastResoultionView = UIView()
//        pastResoultionView.frame = resoultionBar.frame
//        pastResoultionView.backgroundColor = UIColor.red
//        view.addSubview(pastResoultionView)
    }

    @IBOutlet var repeatNumberLabel: UILabel!
    var repeatNumber: Int = 1

    private let cellIdentifier = "cell"
    // Trackingfaceを使うための設定
    private let defaultConfiguration: ARFaceTrackingConfiguration = {
        let configuration = ARFaceTrackingConfiguration()
        return configuration
    }()

    @IBOutlet var resoultionBar: UIView!

    private var resolutinMoveView: UIView!
    // var NetWork = NetWorkViewController()
    // ゴールの目標セルを決める
    // var goalPositionInt: [Int] = [15, 14, 13, 12, 11, 10, 20, 16, 17, 18, 19]
    // ゴールの目標位置を決める.数だけは合わせる必要がある
    var goalPosition: [Float] = [15, 14, 13, 12, 11, 10, 20, 16, 17, 18, 19]
    private var tapData: [[Float]] = [[]]
    private var nowgoal_Data: [Float] = []
    let callibrationArr: [String] = ["口左", "口右", "口上", "口下", "頰右", "頰左", "眉上", "眉下", "右笑", "左笑", "上唇", "下唇", "普通"]
    // 初期設定のためのMAXの座標を配列を保存する
    var callibrationPosition: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    // 初期設定のMINの普通の状態を保存する
    var callibrationOrdinalPosition: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var documentInteraction: UIDocumentInteractionController!

    var depthImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // depthMap generate by code
//        depthImageView = UIImageView()
//        depthImageView!.frame = CGRect(x: 550, y: 280, width: 640, height: 480)
//        view.addSubview(depthImageView)

        // goalPositionInt = Utility.goalPositionInt
        addResolutionMemoryView()
        createScrollVIew()
        decideGoalpositionTimeCount()
        createGoalView()
        initialCallibrationSettings()

        sceneView.delegate = self
        myCollectionView.contentOffset.x = firstStartPosition
        userDefaults.set(myCollectionView.contentOffset.x, forKey: "nowCollectionViewPosition")
        //timeInterval秒に一回update関数を動かす
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }

    @objc func update() {
        DispatchQueue.main.async {
            self.tracking.backgroundColor = UIColor.white
        }
    }

    var resolutionPositionInt = [Int]()
    var resolutionPosition = [Float]()
    var resoultionVarSideMaxNumber: Int = 15
    func addResolutionMemoryView() {
        for i in 1 ... resoultionVarSideMaxNumber {
            let pastResoultionView = UIView()
            let x = faceResoultionMemoryView.frame.size.width / 2
            let y = faceResoultionMemoryView.frame.origin.y
            pastResoultionView.frame.origin.x = x + CGFloat(i * 20)
            pastResoultionView.frame.origin.y = 0
            pastResoultionView.frame.size.width = 10
            pastResoultionView.frame.size.height = resoultionBar.frame.size.height
            pastResoultionView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 0.3)
            faceResoultionMemoryView.addSubview(pastResoultionView)
            resolutionPositionInt.append(i)
            resolutionPosition.append(Float(pastResoultionView.frame.origin.x + pastResoultionView.frame.size.width / 2))
        }
        for i in 1 ... resoultionVarSideMaxNumber {
            let pastResoultionView = UIView()
            let x = faceResoultionMemoryView.frame.size.width / 2
            let y = faceResoultionMemoryView.frame.origin.y
            pastResoultionView.frame.origin.x = x - CGFloat(i * 20)
            pastResoultionView.frame.origin.y = 0
            pastResoultionView.frame.size.width = 10
            pastResoultionView.frame.size.height = resoultionBar.frame.size.height
            pastResoultionView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 0.3)
            faceResoultionMemoryView.addSubview(pastResoultionView)
            resolutionPositionInt.append(15 + i)
            resolutionPosition.append(Float(pastResoultionView.frame.origin.x + pastResoultionView.frame.size.width / 2))
        }
        print(resolutionPosition)
        print(resolutionPositionInt)
        resoultionBar.frame.origin.x = faceResoultionMemoryView.frame.origin.x + faceResoultionMemoryView.frame.size.width / 2
        resoultionBar.frame.origin.y = -30
        resoultionBar.frame.size.width = 1
        resoultionBar.frame.size.height = resoultionBar.frame.size.height + 60
        resoultionBar.backgroundColor = UIColor.black
        faceResoultionMemoryView.addSubview(resoultionBar)
    }

    // Cellの総数を返す
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 300
    }

    // Cellに値を設定する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! CollectionViewCell
        cell.textLabel?.text = indexPath.row.description
        return cell
    }

    private func initialCallibrationSettings() {
        for x in 0 ... 11 {
            if let value = userDefaults.string(forKey: callibrationArr[x]) {
                callibrationPosition[x] = Float(value)!
            } else {
                print("no value", x)
            }
        }
        for x in 0 ... 11 {
            callibrationOrdinalPosition[x] = userDefaults.float(forKey: "普通" + callibrationArr[x])
        }
    }

    // scrolViewを作成する
    private func createScrollVIew() {
        myCollectionView = Utility.createScrollView(directionString: "horizonal")
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        // view.addSubview(myCollectionView)
    }

    private func decideGoalpositionTimeCount() {
        goalLabel.text = String(goalPositionInt[0])
        for i in 0 ..< goalPositionInt.count {
            goalPosition[i] = Float(goalPositionInt[i] * 100 - 200)
        }
        timeCount.maximumValue = 60
        timeCount.minimumValue = 0
        timeCount.value = 0
    }

    private func createGoalView() {
        print("a") // view.addSubview(Utility.createGoalView(directionString: "horizonal"))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.session.run(defaultConfiguration)
        // NetWork.startConnection(to: "a")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
        // NetWork.stopConnection()
    }

    var lastValueR: CGFloat = 0
    // LPFの比率
    var LPFRatio: CGFloat = 0.9

    var maxValueR: CGFloat = 0
    var noiseThreshold: CGFloat = 0.8
    // right scroll
    private func rightScrollMainThread(ratio: CGFloat) {
        DispatchQueue.main.async {
            if self.myCollectionView.contentOffset.x > 6000 {
                return
            }
            if (ratio - self.lastValueL > self.noiseThreshold) || (self.lastValueL - ratio > self.noiseThreshold) {
                return
            }
//            if (self.lastValueL < ratio - self.noiseThreshold) || (self.lastValueL > ratio - self.noiseThreshold) {
//                return
//            }
            self.functionalExpression.value = Float(ratio)
            self.functionalExpressionLabel.text = String(Float(ratio))

            let outPutLPF = self.LPFRatio * self.lastValueL + (1 - self.LPFRatio) * ratio
            self.lastValueL = outPutLPF

            if self.inputMethodString == "velocity" {
                let changedRatio = self.scrollRatioChange(ratio)
                self.myCollectionView.contentOffset = CGPoint(x: self.myCollectionView.contentOffset.x + 10 * changedRatio * CGFloat(self.ratioChange), y: 0)
//            } else if self.inputMethodString == "position" {
//                self.myCollectionView.contentOffset = CGPoint(x: 300 * ratio * CGFloat(self.ratioChange), y: 0)
            } else if self.inputMethodString == "position" {
                self.resoultionBar.transform = CGAffineTransform(translationX: outPutLPF * 300, y: 0)
                self.userDefaults.set(ratio, forKey: "ratio")
                return
            }
        }
    }

    var lastValueL: CGFloat = 0
    var maxValueL: CGFloat = 0
    // left scroll
    private func leftScrollMainThread(ratio: CGFloat) {
        DispatchQueue.main.async {
            if self.myCollectionView.contentOffset.x < 0 {
                return
            }
            if (ratio - self.lastValueL > self.noiseThreshold) || (self.lastValueL - ratio > self.noiseThreshold) {
                return
            }
            self.functionalExpression.value = -Float(ratio)
            self.functionalExpressionLabel.text = String(Float(-ratio))
            let outPutLPF = self.LPFRatio * self.lastValueL + (1 - self.LPFRatio) * ratio
            self.lastValueL = outPutLPF
            if self.inputMethodString == "velocity" {
                let changedRatio = self.scrollRatioChange(ratio)
                self.myCollectionView.contentOffset = CGPoint(x: self.myCollectionView.contentOffset.x - 10 * changedRatio * CGFloat(self.ratioChange), y: 0)
//            } else if self.inputMethodString == "position" {
//                self.myCollectionView.contentOffset = CGPoint(x: -300 * ratio * CGFloat(self.ratioChange), y: 0)
            } else if self.inputMethodString == "position" {
                self.resoultionBar.transform = CGAffineTransform(translationX: -outPutLPF * 300, y: 0)
                self.userDefaults.set(ratio, forKey: "ratio")
                return
            }
        }
    }

    private func scrollRatioChange(_ ratioValue: CGFloat) -> CGFloat {
        var changeRatio: CGFloat = 0
        // y = 1.5x^2
        // changeRatio = 1.5 * ratioValue * ratioValue

//        if ratioValue < 0.25 {
//            changeRatio = ratioValue * 0.2
//        } else if ratioValue > 0.55 {
//            changeRatio = (ratioValue - 0.55) * 1.5 + 0.35
//        } else {
//            changeRatio = ratioValue - 0.25 + 0.05
//        }
        changeRatio = tanh((ratioValue * 3 - 1.5 - 0.8) * 3.14 / 2) * 0.7 + 0.7

        // changeRatio = ratioValue

//        if ratioValue < 0.55 {
//            changeRatio = 0.10
//        } else if ratioValue > 0.55 {
//            changeRatio = 1
//        }

        // print(changeRatio, "changeRatio")
//        if ratioValue < 0.25 {
//            changeRatio = ratioValue * 0.2
//        } else if ratioValue > 0.55 {
//            changeRatio = ratioValue * 1.5
//        } else {
//            changeRatio = ratioValue
//        }
        return changeRatio
    }

    // MARK: - ARSCNViewDelegate

    func session(_: ARSession, didFailWithError _: Error) {
        // Present an error message to the user
    }

    func sessionWasInterrupted(_: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }

    func sessionInterruptionEnded(_: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    var i: Int = 0
    var time: Int = 0
    //tarcking状態
    var tableViewPosition: CGFloat = 0
    var myCollectionViewPosition: CGFloat = 0
    var before_cheek_right: Float = 0
    var after_cheek_right: Float = 0
    var before_cheek_left: Float = 0
    var after_cheek_left: Float = 0
    let sound: SystemSoundID = 1013

    var dataAppendBool = true

    var handsSliderValue: Float = 0
    var workTime: Float = 0
    var transTrans = CGAffineTransform() // 移動
    func renderer(_: SCNSceneRenderer, didUpdate _: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }

        // print(faceAnchor.transform.columns.3)

        //  認識していたら青色に
        DispatchQueue.main.async {
            // print(self.tableView.contentOffset.y)
            self.inputClutchView.backgroundColor = UIColor.red
            self.tracking.backgroundColor = UIColor.blue
        }

        //  認識していたら青色に
        DispatchQueue.main.async {
            if self.nowgoal_Data.count % 120 == 0 {
                self.orietationLabel.text = String(Float(self.nowgoal_Data.count / 120) - self.workTime)
                //                self.userDefaults.set(self.myCollectionView.contentOffset.x, forKey: "nowCollectionViewPosition")
                // print(self.tableView.contentOffset.y)
                if (Float(self.nowgoal_Data.count / 120) - self.workTime) > 60 {
                    self.inputClutchView.backgroundColor = UIColor.white
                }
            }
        }
        func createSuccessResolutionView(number: Int) {
            let SuccessResolutionView = UIView()
            var x = resolutionPosition[number]
            var y = 50
            SuccessResolutionView.frame.origin.x = CGFloat(x - 5)
            SuccessResolutionView.frame.origin.y = CGFloat(0)
            SuccessResolutionView.frame.size.width = 10
            SuccessResolutionView.frame.size.height = resoultionBar.frame.size.height
            SuccessResolutionView.backgroundColor = UIColor(red: 0, green: 0.2, blue: 0.6, alpha: 0.8)
            faceResoultionMemoryView.addSubview(SuccessResolutionView)

            let nextResolutionView = UIView()
            if number < resolutionPositionInt.count {
                x = resolutionPosition[number + 1]
                y = 50
                nextResolutionView.frame.origin.x = CGFloat(x - 5)
                nextResolutionView.frame.origin.y = CGFloat(0)
                nextResolutionView.frame.size.width = 10
                nextResolutionView.frame.size.height = resoultionBar.frame.size.height
                nextResolutionView.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0.1, alpha: 0.3)
                faceResoultionMemoryView.addSubview(nextResolutionView)
            }
        }

        // let goal = goalPosition[self.i]
        let goal = CGFloat(resolutionPosition[self.i])
        DispatchQueue.main.async {
            self.myCollectionViewPosition = self.myCollectionView.contentOffset.x
            let nowPosition = self.resoultionBar.frame.origin.x + self.resoultionBar.frame.size.width / 2
            // 目標との距離が近くなったら
            print(nowPosition, "goal:", goal)
            if nowPosition - goal < 5, goal - nowPosition < 5 {
                print("クリア")
                self.time = self.time + 1
                self.timeCount.value = Float(self.time)
                if self.time > 60 {
                    createSuccessResolutionView(number: self.i)
                    print("クリア2")
                    AudioServicesPlaySystemSound(self.sound)
                    if self.i < self.resolutionPositionInt.count - 1 {
                        self.i = self.i + 1
                        self.timeCount.value = 0
                        self.buttonLabel.backgroundColor = UIColor.blue
                        if self.i == self.resolutionPositionInt.count - 1 {
                            self.goalLabel.text = "次:" + String(self.resolutionPositionInt[self.i])
                        } else {
                            self.goalLabel.text = "次:" + String(self.resolutionPositionInt[self.i]) + "---次の次:" + String(self.resolutionPositionInt[self.i + 1])
                        }
                    } else {
                        self.myCollectionView.contentOffset.x = firstStartPosition
                        if self.repeatNumber != 1 {
                            self.goalLabel.text = "終了!" + String(Float(self.nowgoal_Data.count / 120) - self.workTime) + "秒かかった"
                            self.workTime = Float(self.nowgoal_Data.count / 120)
                        } else {
                            self.workTime = Float(self.nowgoal_Data.count / 120)
                            self.goalLabel.text = "終了." + String(self.workTime) + "sかかった"
                        }
                        self.dataAppendBool = false
                        self.repeatNumber = self.repeatNumber + 1
                        self.time = 0
                        self.userDefaults.set(self.myCollectionView.contentOffset.x, forKey: "nowCollectionViewPosition")
                        // データをパソコンに送る(今の場所と目標地点)
                        DispatchQueue.main.async {
                            self.repeatNumberLabel.text = String(self.repeatNumber) + "回目"
                            // self.NetWork.send(message: [0,0])
                        }
                    }
                }
            } else {
                self.time = 0
            }
        }
        let eyeDownL = faceAnchor.blendShapes[.eyeBlinkLeft] as! Double
        let eyeDownR = faceAnchor.blendShapes[.eyeBlinkRight] as! Double
        // print(eyeDownL)
        if (eyeDownL > 0.3) || eyeDownR > 0.3 {
            return
        }
        // CSVを作るデータに足していく
        if dataAppendBool == true {
            DispatchQueue.main.async {
                if self.i > 0 {
                    // self.tapData.append([(Float(self.tableViewPosition)),(self.goalPosition[self.i])])
                    self.nowgoal_Data.append(Float(self.myCollectionViewPosition + 25))
                    self.nowgoal_Data.append(Float(self.resolutionPositionInt[self.i]))
                }
            }
        }

        let changeAction = changeNum % 7

        switch changeAction {
        case 0:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("MouthRL", for: .normal)
            }
            let mouthLeftBS = faceAnchor.blendShapes[.mouthLeft] as! Float
            let mouthRightBS = faceAnchor.blendShapes[.mouthRight] as! Float
            var mouthLeft: Float = 0
            var mouthRight: Float = 0
            if callibrationUseBool == true {
                mouthLeft = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][0], maxFaceAUVertex: callibrationPosition[0], minFaceAUVertex: callibrationOrdinalPosition[0])
                // print("mouthLeft", mouthLeft)
                mouthRight = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][0], maxFaceAUVertex: callibrationPosition[1], minFaceAUVertex: callibrationOrdinalPosition[1])
            } else {
                mouthLeft = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[638][0], maxFaceAUVertex: 0.008952, minFaceAUVertex: 0.021727568)
                // print("mouthLeft", mouthLeft)
                mouthRight = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[405][0], maxFaceAUVertex: -0.004787985, minFaceAUVertex: -0.0196867)
            }
//            if mouthLeft < 0.1, mouthRight < 0.1 {
//                return
//            }

//            print(mouthLeft, mouthRight)
//            if mouthLeft > mouthRight, mouthRightBS > 0.001 {
//                leftScrollMainThread(ratio: CGFloat(mouthLeft))
//
//            } else if mouthRight > mouthLeft, mouthLeftBS > 0.001 {
//                rightScrollMainThread(ratio: CGFloat(mouthRight))
//            }
            // print(mouthLeft, mouthRight)
            if mouthLeft > mouthRight {
                leftScrollMainThread(ratio: CGFloat(mouthLeft))

            } else if mouthRight > mouthLeft {
                rightScrollMainThread(ratio: CGFloat(mouthRight))
            }

        case 1:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("mouthHalfSmile", for: .normal)
            }

            let cheekSquintLeft = faceAnchor.blendShapes[.mouthSmileLeft] as! Float
            let cheekSquintRight = faceAnchor.blendShapes[.mouthSmileRight] as! Float
            var cheekR: Float = 0
            var cheekL: Float = 0
            if callibrationUseBool == true {
                //                let cheekR = Utility.faceAURangeChange(faceAUVertex: cheekSquintLeft, maxFaceAUVertex: callibrationPosition[8], minFaceAUVertex: callibrationOrdinalPosition[8])
                //
                //                let cheekL = Utility.faceAURangeChange(faceAUVertex: cheekSquintRight, maxFaceAUVertex: callibrationPosition[9], minFaceAUVertex: callibrationOrdinalPosition[9])
                cheekR = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[638][0], maxFaceAUVertex: callibrationPosition[8], minFaceAUVertex: callibrationOrdinalPosition[8])

                cheekL = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[405][0], maxFaceAUVertex: callibrationPosition[9], minFaceAUVertex: callibrationOrdinalPosition[9])
                //
                //                if cheekR < 0.1, cheekL < 0.1 {
                //                    return
                //                }
            } else {
                cheekR = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[638][0], maxFaceAUVertex: callibrationPosition[8], minFaceAUVertex: callibrationOrdinalPosition[8])

                cheekL = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[405][0], maxFaceAUVertex: callibrationPosition[9], minFaceAUVertex: callibrationOrdinalPosition[9])
                //
                //                if cheekSquintLeft < 0.1, cheekSquintRight < 0.1 {
                //                    return
                //                }
            }
            if cheekL > cheekR {
                leftScrollMainThread(ratio: CGFloat(cheekL))
            } else {
                rightScrollMainThread(ratio: CGFloat(cheekR))
            }

        case 2:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("Brow", for: .normal)
            }
            var browInnerUp: Float = 0
            var browDownLeft: Float = 0
            if callibrationUseBool == true {
                browInnerUp = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[762][1], maxFaceAUVertex: callibrationPosition[6], minFaceAUVertex: callibrationOrdinalPosition[6])
                browDownLeft = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[762][1], maxFaceAUVertex: callibrationPosition[7], minFaceAUVertex: callibrationOrdinalPosition[7])
            } else {
                browInnerUp = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[762][1], maxFaceAUVertex: 0.053307146, minFaceAUVertex: 0.04667869)
                // print("mouthLeft", mouthLeft)
                browDownLeft = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[762][1], maxFaceAUVertex: 0.043554213, minFaceAUVertex: 0.04667869)
//                if let browInnerUp = faceAnchor.blendShapes[.browInnerUp] as? Float {
//                    if browInnerUp > 0.5 {
//                        leftScrollMainThread(ratio: CGFloat(browInnerUp - 0.4) * 1.5)
//                    }
//                }
//
//                if let browDownLeft = faceAnchor.blendShapes[.browDownLeft] as? Float {
//                    if browDownLeft > 0.2 {
//                        rightScrollMainThread(ratio: CGFloat(browDownLeft))
//                    }
//                }
            }
//            if browInnerUp < 0.1, browDownLeft < 0.1 {
//                return
//            }
            if browInnerUp > browDownLeft {
                leftScrollMainThread(ratio: CGFloat(browInnerUp))
            } else {
                rightScrollMainThread(ratio: CGFloat(browDownLeft))
            }

        case 3:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("mouthUpDown", for: .normal)
            }
            // let callibrationArr:[String]=["口左","口右","口上","口下","頰右","頰左","眉上","眉下","右笑","左笑","普通","a","b"]
            var mouthUp: Float = 0
            var mouthDown: Float = 0
            if callibrationUseBool == true {
                mouthUp = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][1], maxFaceAUVertex: callibrationPosition[2], minFaceAUVertex: callibrationOrdinalPosition[2])
                mouthDown = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][1], maxFaceAUVertex: callibrationPosition[3], minFaceAUVertex: callibrationOrdinalPosition[3])
            } else {
                mouthUp = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][1], maxFaceAUVertex: -0.03719348, minFaceAUVertex: -0.04107782)
                mouthDown = Utility.faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][1], maxFaceAUVertex: -0.04889179, minFaceAUVertex: -0.04107782)
            }
//             if mouthUp < 0.1, mouthDown < 0.1 {
//                 return
//             }
            if mouthUp > mouthDown {
                leftScrollMainThread(ratio: CGFloat(mouthUp))
            } else {
                rightScrollMainThread(ratio: CGFloat(mouthDown))
            }
        case 4:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("cheekPuff", for: .normal)
            }
            let cheekR = Utility.faceAURangeChange(faceAUVertex: (faceAnchor.geometry.vertices[697][2] + faceAnchor.geometry.vertices[826][2] + faceAnchor.geometry.vertices[839][2]) / 3, maxFaceAUVertex: callibrationPosition[4], minFaceAUVertex: callibrationOrdinalPosition[4])
            let cheekL = Utility.faceAURangeChange(faceAUVertex: (faceAnchor.geometry.vertices[245][2] + faceAnchor.geometry.vertices[397][2] + faceAnchor.geometry.vertices[172][2]) / 3, maxFaceAUVertex: callibrationPosition[5], minFaceAUVertex: callibrationOrdinalPosition[5])
//            if cheekR < 0.1, cheekL < 0.1 {
//                return
//            }
            // print(cheekL, cheekR, faceAnchor.geometry.vertices[24][0])
            if cheekL > cheekR, faceAnchor.geometry.vertices[24][0] > 0 {
                leftScrollMainThread(ratio: CGFloat(cheekL))
            } else if cheekR > cheekL, faceAnchor.geometry.vertices[24][0] < 0 {
                rightScrollMainThread(ratio: CGFloat(cheekR))
            }
        case 5:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("ripRoll", for: .normal)
            }
            let mouthRollUpper = faceAnchor.blendShapes[.mouthRollUpper] as! Float
            let mouthRollLower = faceAnchor.blendShapes[.mouthRollLower] as! Float
            var leftCheek: Float = 0
            var rightCheek: Float = 0
            return
            if callibrationUseBool == true {
            } else {
                if mouthRollUpper < 0.1, mouthRollLower < 0.1 {
                    return
                }
                if mouthRollUpper > mouthRollLower {
                    rightScrollMainThread(ratio: CGFloat(mouthRollUpper))
                } else {
                    leftScrollMainThread(ratio: CGFloat(mouthRollLower))
                }
            }
            if rightCheek > leftCheek {
                leftScrollMainThread(ratio: CGFloat(rightCheek))
            } else {
                rightScrollMainThread(ratio: CGFloat(leftCheek))
            }
        default:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("Hands", for: .normal)
                self.handsSliderValue = self.handsSlider.value
            }
            if handsSliderValue > 0 {
                rightScrollMainThread(ratio: CGFloat(handsSliderValue))
            } else {
                leftScrollMainThread(ratio: CGFloat(-handsSliderValue))
            }
        }
    }

    func createCSV(fileArrData: [Float]) {
        let CSVFileData = Utility.createCSVFileData(fileArrData: fileArrData, facailAU: buttonLabel.titleLabel!.text!, direction: "horizonal", inputMethod: inputMethodString)
        let fileName = CSVFileData.fileName
        let fileStrData = CSVFileData.fileData
        // DocumentディレクトリのfileURLを取得
        let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!

        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
        let FilePath = documentDirectoryFileURL.appendingPathComponent(fileName)

        print("書き込むファイルのパス: \(FilePath)")

        do {
            try fileStrData.write(to: FilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("failed to write: \(error)")
        }

        documentInteraction = UIDocumentInteractionController(url: FilePath)
        documentInteraction.presentOpenInMenu(from: CGRect(x: 10, y: 10, width: 100, height: 50), in: view, animated: true)
        nowgoal_Data = []
        repeatNumber = 1
        repeatNumberLabel.text = String(repeatNumber) + "回目"
    }
}
