//
//  SphereEmitterView.swift
//  Sudoku
//
//  Created by 박재우 on 1/31/24.
//

import UIKit
import RxSwift

class SphereEmitterView: UIView {

    private var emitterLayer = CAEmitterLayer()
    private let tapSubject = PublishSubject<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupEmitter()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // MARK: - emit 위치 및 크기
        // emit 하는 중심점
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.height / 3)

        // emit 하는 모양의 크기
        // 현재 모양은 3D 형태의 반지름을 표현
        emitterLayer.emitterSize = CGSize(width: bounds.width / 1.5, height: 0)
    }

    private func setupEmitter() {
        // MARK: - 생성되는 속도
        emitterLayer.birthRate = 3

        // MARK: - emit 된 객체 생명 시간
        emitterLayer.lifetime = 3

        // MARK: - 뿌려지는 모양
        emitterLayer.emitterShape = .sphere

        // MARK: - emit 되는 속도
        emitterLayer.velocity = 2

        let fireworks = generateFireworkCells()
        emitterLayer.emitterCells = [fireworks]

        layer.addSublayer(emitterLayer)
        isHidden = true
    }

    private func generateFireworkCells() -> CAEmitterCell {
        let cell = CAEmitterCell()

        cell.birthRate = 10
        cell.lifetime = 2.0

        // MARK: - 색상 alpha값 줄어드는 오차범위
         cell.alphaRange = 0.5
         cell.alphaSpeed = -0.2

        // MARK: 속도관련
        // 클수록 방향 전환 영향도 커짐
        cell.velocity = 100
        cell.velocityRange = 5
            
        // y방향으로 가속도
        cell.yAcceleration = 100

        // 효과 뿌려지는 방향과 각도 조절
        cell.emissionLongitude = .pi / 2
        cell.emissionRange = .pi

        // 셀의 회전 속도와 값
        cell.spin = 3
        cell.spinRange = 3

        // 셀의 크기 배율 값과 범위 그리고 속도
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.scaleSpeed = 0.05

        cell.contents = UIImage(resource: .bear).cgImage

        return cell
    }

    @objc private func tappedEmitterView() {
        tapSubject.onNext(())
    }

    func emit() {
        isHidden = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedEmitterView))
        self.addGestureRecognizer(tapGesture)
    }


    func remove() {
        emitterLayer.removeFromSuperlayer()
    }

    func observeTap() -> Observable<Void> {
        tapSubject.asObservable()
    }
}
