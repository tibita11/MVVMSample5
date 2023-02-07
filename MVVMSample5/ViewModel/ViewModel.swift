//
//  ViewModel.swift
//  MVVMSample5
//
//  Created by 鈴木楓香 on 2023/02/07.
//

import Foundation
import RxSwift
import RxCocoa

struct ViewModelInput {
    let startButton: Observable<Void>
    let stopButton: Observable<Void>
    let resetButton: Observable<Void>
}

protocol ViewModelOutput {
    var countTimerLabel: Driver<String?> { get }
    var isStartEnabled: Driver<Bool> { get }
    var isStopEnabled: Driver<Bool> { get }
}

protocol ViewModelType {
    var outputs: ViewModelOutput? { get }
    func setup(input: ViewModelInput)
}

class ViewModel: ViewModelType {
    
    var outputs: ViewModelOutput?
    
    private let countRelay = BehaviorRelay<Int>(value: 0)
    private let isStartRelay = PublishRelay<Bool>()
    private let isStopRelay = PublishRelay<Bool>()
    
    private let disposeBag = DisposeBag()
    
    private var timer: Timer?
    private let initialCount = 0
    
    init() {
        self.outputs = self
    }
    
    func setup(input: ViewModelInput) {
        input.startButton.subscribe(onNext: { [weak self] in
            self!.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                let count = self!.countRelay.value + 1
                self!.countRelay.accept(count)
            }
            self!.isStartRelay.accept(false)
            self!.isStopRelay.accept(true)
        })
        .disposed(by: disposeBag)
        
        input.stopButton.subscribe(onNext: { [weak self] in
            guard let timer = self!.timer else { return }
            timer.invalidate()
            
            self!.isStartRelay.accept(true)
            self!.isStopRelay.accept(false)
        })
        .disposed(by: disposeBag)
        
        input.resetButton.subscribe(onNext: { [weak self] in
            if let timer = self!.timer, timer.isValid {
                timer.invalidate()
            }
            
            self!.countRelay.accept(self!.initialCount)
            
            self!.isStartRelay.accept(true)
            self!.isStopRelay.accept(false)
        })
        .disposed(by: disposeBag)
    }
    
    
}

extension ViewModel: ViewModelOutput {
    var isStartEnabled: Driver<Bool> {
        return isStartRelay
            .asDriver(onErrorJustReturn: false)
    }
    
    var isStopEnabled: Driver<Bool> {
        return isStopRelay
            .asDriver(onErrorJustReturn: false)
    }
    
    var countTimerLabel: Driver<String?> {
        return countRelay
            .map { "\($0)秒" }
            .asDriver(onErrorJustReturn: nil)
    }
    
    
}
