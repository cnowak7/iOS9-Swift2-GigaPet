//
//  ViewController.swift
//  mylittlemonster
//
//  Created by Chris Nowak on 5/26/16.
//  Copyright © 2016 Chris Nowak Tho, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // IBOutlets
    
    @IBOutlet weak var monsterImageView: MonsterImageView!
    @IBOutlet weak var foodImageView: DragImage!
    @IBOutlet weak var heartImageView: DragImage!
    @IBOutlet weak var penalty1ImageView: UIImageView!
    @IBOutlet weak var penalty2ImageView: UIImageView!
    @IBOutlet weak var penalty3ImageView: UIImageView!
    @IBOutlet weak var playAgainButton: UIButton!
    
    // Variables
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: NSTimer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
    
    var musicPlayer: AVAudioPlayer!
    var soundEffectsBite: AVAudioPlayer!
    var soundEffectsHeart: AVAudioPlayer!
    var soundEffectsDeath: AVAudioPlayer!
    var soundEffectsSkull: AVAudioPlayer!
    
    // View Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        foodImageView.dropTarget = monsterImageView
        heartImageView.dropTarget = monsterImageView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.itemDroppedOnCharacter(_:)), name: "onTargetDropped", object: nil)
        do {
            try musicPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!))
            try soundEffectsBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            try soundEffectsHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            try soundEffectsDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            try soundEffectsSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            soundEffectsBite.prepareToPlay()
            soundEffectsHeart.prepareToPlay()
            soundEffectsDeath.prepareToPlay()
            soundEffectsSkull.prepareToPlay()
        } catch let error as NSError {
            print(error.debugDescription)
        }
        setUpNewGame()
    }
    
    // Custom Helper Methods
    
    func setUpNewGame() {
        penalty1ImageView.alpha = DIM_ALPHA
        penalty2ImageView.alpha = DIM_ALPHA
        penalty3ImageView.alpha = DIM_ALPHA
        monsterImageView.playIdleAnimation()
        setRandomOption()
        startTimer()
    }
    
    func itemDroppedOnCharacter(notification: AnyObject) {
        monsterHappy = true
        startTimer()
        disableFoodOption()
        disableHeartOption()
        if currentItem == 0 {
            soundEffectsHeart.play()
        } else {
            soundEffectsBite.play()
        }
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(ViewController.changeGameState), userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        if !monsterHappy {
            penalties += 1
            soundEffectsSkull.play()
            if penalties == 1 {
                penalty1ImageView.alpha = OPAQUE
                penalty2ImageView.alpha = DIM_ALPHA
            } else if penalties == 2 {
                penalty2ImageView.alpha = OPAQUE
                penalty3ImageView.alpha = DIM_ALPHA
            } else if penalties >= 3 {
                penalty3ImageView.alpha = OPAQUE
            } else {
                penalty1ImageView.alpha = DIM_ALPHA
                penalty2ImageView.alpha = DIM_ALPHA
                penalty3ImageView.alpha = DIM_ALPHA
            }
            if penalties >= MAX_PENALTIES {
                gameOver()
            }
        }
        setRandomOption()
        monsterHappy = false
    }
    
    func setRandomOption() {
        let rand = arc4random_uniform(2) // 0 or 1
        if rand == 0 {
            disableFoodOption()
            enableHeartOption()
        } else {
            disableHeartOption()
            enableFoodOption()
        }
        currentItem = rand
    }
    
    func enableHeartOption() {
        heartImageView.alpha = OPAQUE
        heartImageView.userInteractionEnabled = true
    }
    
    func disableHeartOption() {
        heartImageView.alpha = DIM_ALPHA
        heartImageView.userInteractionEnabled = false
    }
    
    func enableFoodOption() {
        foodImageView.alpha = OPAQUE
        foodImageView.userInteractionEnabled = true
    }
    
    func disableFoodOption() {
        foodImageView.alpha = DIM_ALPHA
        foodImageView.userInteractionEnabled = false
    }
    
    func gameOver() {
        timer.invalidate()
        monsterImageView.playDeathAnimation()
        soundEffectsDeath.play()
        playAgainButton.hidden = false
    }
    
    // IBActions
    
    @IBAction func playAgainButtonPressed(sender: AnyObject) {
        penalties = 0
        monsterHappy = false
        playAgainButton.hidden = true
        setUpNewGame()
    }
    
}

