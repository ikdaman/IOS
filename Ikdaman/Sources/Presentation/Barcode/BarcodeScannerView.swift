//
//  BarcodeScannerView.swift
//  Ikdaman
//
//  Created by 이재혁 on 5/25/25.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

protocol BarcodeScannerViewDelegate: AnyObject {
    func barcodeScannerView(_ view: BarcodeScannerView, didScan code: String, type: AVMetadataObject.ObjectType)
    func barcodeScannerViewDidRequestClose(_ view: BarcodeScannerView)
    func barcodeScannerView(_ view: BarcodeScannerView, didFailWithError error: BarcodeScannerError)
}

// MARK: - Error Types
enum BarcodeScannerError: Error {
    case cameraNotAvailable
    case cameraInputFailed
    case metadataOutputFailed
    case permissionDenied
    
    var localizedDescription: String {
        switch self {
        case .cameraNotAvailable:
            return "카메라를 찾을 수 없습니다."
        case .cameraInputFailed:
            return "카메라 입력을 설정할 수 없습니다."
        case .metadataOutputFailed:
            return "메타데이터 출력을 설정할 수 없습니다."
        case .permissionDenied:
            return "카메라 권한이 거부되었습니다."
        }
    }
}

class BarcodeScannerView: UIView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let actionTriggers = PublishRelay<BarcodeScannerriggerType>()
    
    weak var delegate: BarcodeScannerViewDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - UI Elements
    private lazy var naviBarView = UIView().then {
        $0.addSubviews([backBtn, naviTitleLabel, closeButton])
        
        backBtn.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.left.equalToSuperview().inset(13)
            $0.size.equalTo(26)
        }
        
        naviTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backBtn)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(backBtn)
            $0.right.equalToSuperview().inset(14)
            $0.size.equalTo(26)
        }
    }
    
    private let backBtn = UIButton().then {
        $0.setImage(UIImage(named: "arrow_left")?.withTintColor(.white), for: .normal)
        $0.contentMode = .scaleAspectFit
    }
    
    private let naviTitleLabel = UILabel().then {
        $0.text = "바코드 스캔하기"
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    lazy var closeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "ic_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    
    private let descLabel1 = UILabel().then {
        $0.text = "바코드를 영역에 맞춰 보세요"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    
    private let descLabel2 = UILabel().then {
        $0.text = "원하는 책을 빠르게 찾을 수 있어요"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    
    private lazy var scanAreaView = UIView().then {
        $0.layer.borderColor = UIColor(hex: "#FFD900").cgColor
        $0.layer.borderWidth = 2
    }
    
    private lazy var overlayView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        attribute()
        bind()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        createOverlayMask()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func setupLayout() {
        addSubviews([overlayView, naviBarView, descLabel1, descLabel2, scanAreaView])
        
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        naviBarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
        }
        
        descLabel1.snp.makeConstraints {
            $0.top.equalTo(naviBarView.snp.bottom).offset(130)
            $0.centerX.equalToSuperview()
        }
        
        descLabel2.snp.makeConstraints {
            $0.top.equalTo(descLabel1.snp.bottom).offset(8)
            $0.centerX.equalTo(descLabel1)
        }
        
        scanAreaView.snp.makeConstraints {
            $0.top.equalTo(descLabel2.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(245)
        }
    }
    
    private func attribute() {
        backgroundColor = .black
    }
    
    private func bind() {
        
    }
    
    func startScanning() {
        guard let captureSession = captureSession else { return }
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
        }
    }
    
    func stopScanning() {
        guard let captureSession = captureSession else { return }
        if captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                captureSession.stopRunning()
            }
        }
    }
    
    private func createOverlayMask() {
        let path = UIBezierPath(rect: bounds)
        let scanAreaFrame = scanAreaView.frame
        let scanAreaPath = UIBezierPath(roundedRect: scanAreaFrame, cornerRadius: 10)
        path.append(scanAreaPath.reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        overlayView.layer.mask = maskLayer
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        // 카메라 디바이스 설정
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.barcodeScannerView(self, didFailWithError: .cameraNotAvailable)
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.barcodeScannerView(self, didFailWithError: .cameraInputFailed)
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.barcodeScannerView(self, didFailWithError: .cameraInputFailed)
            return
        }
        
        // 메타데이터 출력 설정
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // 지원하는 바코드 타입들
            metadataOutput.metadataObjectTypes = [
                .qr,
                .ean8,
                .ean13,
                .pdf417,
                .code128,
                .code39,
                .code93,
                .upce,
                .aztec,
                .dataMatrix
            ]
            
            // 스캔 영역 제한 (선택사항)
            DispatchQueue.main.async { [weak self] in
                self?.setScanningArea(for: metadataOutput)
            }
            
        } else {
            delegate?.barcodeScannerView(self, didFailWithError: .metadataOutputFailed)
            return
        }
        
        // 프리뷰 레이어 설정
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession).then {
            $0.frame = bounds
            $0.videoGravity = .resizeAspectFill
        }
        
        if let previewLayer = previewLayer {
            layer.insertSublayer(previewLayer, at: 0)
        }
        
        // 캡처 세션 시작
        startScanning()
    }
    
    private func setScanningArea(for output: AVCaptureMetadataOutput) {
        guard let previewLayer = previewLayer else { return }
        
        let scanAreaFrame = scanAreaView.frame
        let normalizedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: scanAreaFrame)
        output.rectOfInterest = normalizedRect
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        delegate?.barcodeScannerViewDidRequestClose(self)
    }
    
    private func handleBarcodeDetection(_ code: String, type: AVMetadataObject.ObjectType) {
        // 진동 피드백
//        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
//        impactGenerator.impactOccurred()
        
        // 스캔 일시 정지 (중복 스캔 방지)
        stopScanning()
        
        // 델리게이트로 결과 전달
        delegate?.barcodeScannerView(self, didScan: code, type: type)
    }
    
    // MARK: - Data Binding
    @discardableResult
    func setupDI(setupScanner: Observable<Void>) -> Self {
        setupScanner
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                DispatchQueue.main.async {
                    self.setupCaptureSession()
                }
            })
            .disposed(by: disposeBag)
        
        return self
    }
    
    
    /// 유저 액션
    @discardableResult
    func setupDI(action: PublishRelay<BarcodeScannerriggerType>) -> Self {
        actionTriggers
            .bind(to: action)
            .disposed(by: disposeBag)
        
        return self
    }
}

extension BarcodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            stopScanning()
            actionTriggers.accept(.scannedIsbn(stringValue))
//            handleBarcodeDetection(stringValue, type: readableObject.type)
        }
    }
}
