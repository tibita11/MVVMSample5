//
//  MainViewController.swift
//  MVVMSample5
//
//  Created by 鈴木楓香 on 2023/02/07.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var viewModel: ViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        viewModel = ViewModel()
        let input = ViewModelInput(startButton: startButton.rx.tap.asObservable(), stopButton: stopButton.rx.tap.asObservable(), resetButton: resetButton.rx.tap.asObservable())
        viewModel.setup(input: input)
        
        viewModel.outputs?.countTimerLabel
            .drive(countLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs?.isStartEnabled
            .drive(onNext: { [weak self] bool in
                self!.startButton.isEnabled = bool
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs?.isStopEnabled
            .drive(onNext: { [weak self] bool in
                self!.stopButton.isEnabled = bool
            })
            .disposed(by: disposeBag)
    }


}
