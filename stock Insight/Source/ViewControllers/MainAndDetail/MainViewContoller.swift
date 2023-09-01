import UIKit
import Charts

enum ChartDataType{
    case sentimentalPredict
    case presentPrice
    case predict5day
    case predict10day
    case predict15day
    case KOSPI
    case KOSDAQ
    case KOSPI200
    
}


class MainViewContoller: UIViewController, ChartViewDelegate {
    
    //label, textField
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var stockNameLabel: UILabel!
    @IBOutlet var stockCodeLabel: UILabel!
    
    @IBOutlet var presentPriceLabel: UILabel!
    @IBOutlet var changePriceLabel: UILabel!
    @IBOutlet var arrowLabel: UIImageView!
    
    //button
    @IBOutlet var presentPriceButton: UIButton!
    @IBOutlet var LSTMButton: UIButton!
    @IBOutlet var sentimentalButton: UIButton!
    
    @IBOutlet var kospiButton: UIButton!
    @IBOutlet var kosdaqButton: UIButton!
    @IBOutlet var kospi200Button: UIButton!
    
    
    //chartView를 띄울 UIView
    @IBOutlet var predicePriceView: UIView!
    @IBOutlet var indexView: UIView!
    
    //ChartView
    var predictLineChartView: LineChartView!
    var indexLineChartView: LineChartView!
    
    //data
    var searchStockData: SearchStock?
    var presentStockData: PresentStockData?
    var indexDatas: IndexData?
    
    //뉴스 뷰
    @IBOutlet var everyDayEconomyView: UIView!
    @IBOutlet var hankyungBusinessView: UIView!
    @IBOutlet var economistView: UIView!
    
    
    //Dummy data
    var gradientColor = UIColor.stockInsightBlue
    var datasetName: String = "5d_predict_SE00"
    var searchStockData_Dummy: SearchStock_Dummy?
    var presentStockData_Dummy: PresentStockData_Dummy?
    

    

    


    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //data 가져오기
        //self.getIndexWithAPI() //지수 가져오기
        //self.getPresentStockWithAPI(stockName: "삼성전자") //현재 보여질 주식에 대한 값 가져오기
        self.getPresentStock_Dummy()
        
        
        //뷰 세팅
        self.settingView()
        
        //제스쳐 세팅
        self.gestureSetting()
        
        //주가 그래프 뷰 세팅
        self.predictLineChartView = configureChartView(isPredict: true, color: UIColor.stockInsightBlue, chartDataType: .presentPrice)
        self.indexLineChartView = configureChartView(isPredict: true, color: UIColor.systemOrange, chartDataType: .presentPrice)
        self.predicePriceView.addSubview(predictLineChartView)
        self.indexView.addSubview(indexLineChartView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - 설정 함수
    
    //뷰 세팅
    func settingView(){
        
        guard let currentPrice = self.presentStockData_Dummy?.currentPrice else {return}
        guard let change = self.presentStockData_Dummy?.change else {return}
        let changePrice = 1600
        //주식 변동율 = ((현재 가격 – 이전 가격) / 이전 가격) x 100
        
        
        
        //오늘 날짜 가져오기
        let currentDate = Date()
        let calendar = Calendar.current
        let monthComponent = calendar.component(.month, from: currentDate)
        let dayComponent = calendar.component(.day, from: currentDate)
        self.dateLabel.text = "\(monthComponent)월 \(dayComponent)일"
        
        //현재 주가 데이터 출력
        self.stockNameLabel.text = "현대차"
        self.stockCodeLabel.text = self.presentStockData_Dummy?.stockCode
        self.presentPriceLabel.text = "\(Int(currentPrice))"
        self.changePriceLabel.text = "+\(changePrice)(\(change)%)"
        self.arrowLabel.image = UIImage(systemName: "arrow.up")
        
        
        
        //cornerRadius 설정
        self.presentPriceButton.layer.cornerRadius = 5
        self.LSTMButton.layer.cornerRadius = 5
        self.sentimentalButton.layer.cornerRadius = 5
        self.kospiButton.layer.cornerRadius = 5
        self.kosdaqButton.layer.cornerRadius = 5
        self.kospi200Button.layer.cornerRadius = 5
        self.predicePriceView.layer.cornerRadius = 5
        self.indexView.layer.cornerRadius = 5
    }
    
    //제스쳐 세팅 함수
    func gestureSetting(){
        //gesture
        let everyDayEconodyViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(everyDayEconomyHandleTap(_:)))
        let hankyungBusinessViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(hankyungBusinessHandleTap(_:)))
        let economistViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(economistHandleTap(_:)))
        
        
        self.everyDayEconomyView.addGestureRecognizer(everyDayEconodyViewTapGesture)
        self.hankyungBusinessView.addGestureRecognizer(hankyungBusinessViewTapGesture)
        self.economistView.addGestureRecognizer(economistViewTapGesture)
    }
    
    
    //chartView 생성
    func configureChartView(isPredict: Bool, color: UIColor, chartDataType: ChartDataType ) -> LineChartView{
        let gradient = fillGradient()
        let data = setDataEntry()
        let lineChartView = setLineChartView()
        lineChartView.delegate = self
        return lineChartView
        
        // 그라디언트 채우기 설정
        func fillGradient()-> CGGradient{
            let gradientColor = color
            let gradientColors = [gradientColor.cgColor, UIColor.black.cgColor] as CFArray
            let colorLocations: [CGFloat] = [1.0, 0.0]
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                            colors: gradientColors,
                                            locations: colorLocations) else {
                fatalError("그라디언트 생성 실패했습니다.")
            }
            return gradient
        }
        
        // 데이터 엔트리 생성
        func setDataEntry() -> LineChartData{
            var entries: [ChartDataEntry] = []
            var stockData: [[Date: Double]]? = []
            
            switch chartDataType{
            case .KOSPI:
                stockData = self.indexDatas?.KOSPI
            case .KOSDAQ:
                stockData = self.indexDatas?.KOSDAQ
            case .KOSPI200:
                stockData = self.indexDatas?.KOSPI200
            case .predict10day:
                stockData = parseCSVFile(datasetName: "10d_predict_SE00")
            default:
                stockData = parseCSVFile(datasetName: "5d_predict_SE00")
            }
            
            
            
            //x,y 값 생성
            for entry in stockData! {
                if let date = entry.keys.first, let value = entry.values.first {
                    let xValue = date.timeIntervalSince1970
                    let yValue = value
                    let dataEntry = ChartDataEntry(x: xValue, y: yValue)
                    
                    entries.append(dataEntry)
                }
            }
            
            
            // 데이터셋 생성
            let dataSet = LineChartDataSet(entries: entries, label: "data")
            dataSet.gradientPositions
            dataSet.setColor(color) // 그래프 선 색상 설정
            dataSet.lineWidth = 1.0 // 그래프 선 두께 설정
            dataSet.drawCirclesEnabled = false // 데이터 포인트에 원형 마커 표시 여부 설정
            dataSet.drawValuesEnabled = true //
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
            dataSet.drawFilledEnabled = true // 채우기 활성화
            dataSet.mode = .cubicBezier
            dataSet.cubicIntensity = 0.2
            
            // 데이터 배열 설정
            let data = LineChartData(dataSet: dataSet)
            return data
        }
        
        //lineChartView 생성
        func setLineChartView()->LineChartView{
            // 차트 뷰 설정
            var lineChartView = LineChartView(frame: self.predicePriceView.bounds)
            lineChartView.translatesAutoresizingMaskIntoConstraints = false //autoLayout 지정 속성_ fals = autuLayout 사용
            lineChartView.contentMode = .scaleToFill
            
            //차트 뷰 데이터 설정
            lineChartView.data = data
            
            //차트 뷰 grid 설정
            lineChartView.xAxis.drawGridLinesEnabled = false
            lineChartView.leftAxis.drawGridLinesEnabled = false
            
            
            //차트 뷰 뷰 설정
            lineChartView.xAxis.labelPosition = .bottom // x축 레이블 위치 설정
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: []) // x축 레이블 포맷터 설정 (일단 빈 값으로 설정)
            lineChartView.rightAxis.enabled = false // 오른쪽 축 비활성화
            lineChartView.leftAxis.enabled = false
            lineChartView.legend.enabled = false // 범례 비활성화
            lineChartView.chartDescription.enabled = false // 차트 설명 비활성화
            lineChartView.pinchZoomEnabled = true        // 핀치 줌 기능 비활성화
            lineChartView.scaleXEnabled = true           // X축 스케일 기능 비활성화
            lineChartView.scaleYEnabled = true           // Y축 스케일 기능 비활성화
            lineChartView.doubleTapToZoomEnabled = true
            lineChartView.isUserInteractionEnabled = true
            lineChartView.noDataText = "" //데이터 없을 때 보일 문자열
            lineChartView.xAxis.valueFormatter = DateAxisValueFormatter()
            lineChartView.xAxis.labelCount = 0 // x축 레이블 개수 설정
            lineChartView.xAxis.granularity = 0 // x축 레이블 간격 설정
            lineChartView.xAxis.labelRotationAngle = 0 // x축 레이블 회전 설정
            
            if lineChartView.scaleX >= 2.0 && lineChartView.scaleY >= 2.0 {
                print("==============TRUE=========================")
                print("scaleX = \(lineChartView.scaleX), scaleY = \(lineChartView.scaleY)")
                lineChartView.data?.setDrawValues(true) // 그래프에 값 표시 활성화
            } else {
                print("==============FALSE=========================")
                print("scaleX = \(lineChartView.scaleX), scaleY = \(lineChartView.scaleY)")
                lineChartView.data?.setDrawValues(false) // 그래프에 값 표시 비활성화
            }
            
            if isPredict == true{
                let dateString = "2023/06/07"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let date = dateFormatter.date(from: dateString)
                let doubleValue = date?.timeIntervalSince1970
                
                let limitLine = ChartLimitLine(limit: doubleValue!, label: "") // 특정 x 값에 대한 제한선 생성
                limitLine.lineWidth = 1 // 제한선의 너비 설정
                limitLine.lineColor = .systemRed // 제한선의 색상 설정
                lineChartView.xAxis.addLimitLine(limitLine) // 제한선을 왼쪽 축에 추가
                lineChartView.notifyDataSetChanged()
                lineChartView.setNeedsDisplay()
            }
            
//            //descrpitionLabel
//            descriptionLabel.font = .systemFont(ofSize: 15, weight: .bold)
//            descriptionLabel.textColor = .black
//            contentView.addSubview(descriptionLabel)
//            descriptionLabel.snp.makeConstraints {
//                $0.centerX.equalToSuperview()
//                $0.top.equalToSuperview().offset(10)
//            }
            // 터치 제스처 추가
    //            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleChartTap(_:)))
    //            lineChartView.addGestureRecognizer(tapGesture)
    //
            return lineChartView
        }
    }
    
    
    
    //MARK: - 버튼 함수
    
    //검색 버튼
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        var searchName = self.searchTextField.text ?? ""
        if searchName == "" {
            self.showAlert(title: "검색할 종목을 입력해주세요")
        }
        else{
            //self.searchStockWithAPI(stockName: searchName)
            print("종목 상세화면으로 이동")
            //종목 상세화면으로 이동
            guard let viewController = self.storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController else {return}
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //종목 상세화면 이동 버튼
    @IBAction func stockDetailButtonTapped(_ sender: Any) {
        
        //종목 상세화면으로 이동
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController else {return}
        
        viewController.presentStockData_Dummy = self.presentStockData_Dummy
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    //현재 주가 버튼
    @IBAction func presentPriceButtonTapped(_ sender: Any) {
        self.predictLineChartView.removeFromSuperview()
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.stockInsightBlue, chartDataType: .predict15day)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        self.presentPriceButton.backgroundColor = .darkGray
        self.LSTMButton.backgroundColor = .black
        self.sentimentalButton.backgroundColor = .black
    }
    
    
    //lstm 예측 버튼
    @IBAction func lstmPriceButtonTapped(_ sender: Any) {
        
        self.predictLineChartView.removeFromSuperview()
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemYellow, chartDataType: .predict10day)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        self.presentPriceButton.backgroundColor = .black
        self.LSTMButton.backgroundColor = .darkGray
        self.sentimentalButton.backgroundColor = .black
    }
    
    //감성분석 예측 버튼
    @IBAction func sentimentalPriceButtonTapped(_ sender: Any) {
        
        self.predictLineChartView.removeFromSuperview()
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .predict10day)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        self.presentPriceButton.backgroundColor = .black
        self.LSTMButton.backgroundColor = .black
        self.sentimentalButton.backgroundColor = .darkGray
    }
    
    //kospi지수 버튼
    @IBAction func kospiIndexButtonTapped(_ sender: Any) {
        
        
        
        self.kospiButton.backgroundColor = .darkGray
        self.kosdaqButton.backgroundColor = .black
        self.kospi200Button.backgroundColor = .black
        
    }
    
    //kosdaq지수 버튼
    @IBAction func kosdaqIndexButtonTapped(_ sender: Any) {
        
        
        self.kospiButton.backgroundColor = .black
        self.kosdaqButton.backgroundColor = .darkGray
        self.kospi200Button.backgroundColor = .black
    }
    //kospi200지수 버튼
    @IBAction func kospi200IndexButtonTapped(_ sender: Any) {
        
        
        self.kospiButton.backgroundColor = .black
        self.kosdaqButton.backgroundColor = .black
        self.kospi200Button.backgroundColor = .darkGray
    }
    
    
    
    
    
    //MARK: - Data 관련 함수
    
    //종목 검색 함수
    func searchStockWithAPI(stockName: String){
        SearchStockService.shared.searchStock(stockName: stockName, completion: { (networkResult) in
            switch networkResult{
            case.success(let data):
                guard let searchData = data as? SearchStock else {return}
                self.searchStockData = searchData
                
                //종목 상세화면으로 이동 함수
                guard let viewController = self.storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController else {return}
                self.navigationController?.pushViewController(viewController, animated: true)
                
            case .requestErr(let msg):
                //API 시간 초과
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr in searchStockWithAPI")
            case .serverErr:
                print("serverErr in searchStockWithAPI")
            case .networkFail:
                print("networkFail in searchStockWithAPI")
            default:
                print("networkFail in searchStockWithAPI")
            }
        })
    }
    
    //현재 주가에 대한 데이터 갖고오기 함수
    func getPresentStockWithAPI(stockName: String){
        SearchStockService.shared.searchStock(stockName: stockName, completion: { (networkResult) in
            switch networkResult{
            case.success(let data):
                guard let presentStockData = data as? PresentStockData else {return}
                self.presentStockData = presentStockData
                
            case .requestErr(let msg):
                //API 시간 초과
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr in searchStockWithAPI")
            case .serverErr:
                print("serverErr in searchStockWithAPI")
            case .networkFail:
                print("networkFail in searchStockWithAPI")
            default:
                print("networkFail in searchStockWithAPI")
            }
        })
    }
    
    
    //지수 데이터 가져오기 함수
    func getIndexWithAPI(){
        GetIndexService.shared.getIndex(completion: { (networkResult) in
            switch networkResult{
            case.success(let data):
                guard let indexURLs = data as? IndexURLs else {return}
                let kospiData = self.downloadCSVFile(indexURL: indexURLs.KOSPI)
                let kosdaqData = self.downloadCSVFile(indexURL: indexURLs.KOSDAQ)
                let kospi200Data = self.downloadCSVFile(indexURL: indexURLs.KOSPI200)
                self.indexDatas = IndexData(KOSPI: kospiData, KOSDAQ: kosdaqData, KOSPI200: kospi200Data)
                
            case .requestErr(let msg):
                //API 시간 초과
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr in getIndexWithAPI")
            case .serverErr:
                print("serverErr in getIndexWithAPI")
            case .networkFail:
                print("networkFail in getIndexWithAPI")
            default:
                print("networkFail in getIndexWithAPI")
                
            }
        })
    }
    
    //현재 주가 데이터 Dummy 로 가져오기 함수
    func getPresentStock_Dummy(){
        self.presentStockData_Dummy = PresentStockData_Dummy(currentPrice: 189100, change: 0.69, stockCode: "005380",
                                                             newsURL: "https://www.hankyung.com/",
                                                             magazineURL: "https://www.mk.co.kr/",
                                                             economisURL: "https://economist.co.kr/article/search?searchText=%EC%82%BC%EC%84%B1%EC%A0%84%EC%9E%90")
        
    }
    
    
    //MARK: - 기타 함수

    
    @objc func everyDayEconomyHandleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            guard let urlString = self.presentStockData_Dummy?.magazineURL else {return}
            let websiteURL = URL(string: urlString)
            if let url = websiteURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    @objc func hankyungBusinessHandleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            guard let urlString = self.presentStockData_Dummy?.newsURL else {return}
            let websiteURL = URL(string: urlString)
            if let url = websiteURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    @objc func economistHandleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            guard let urlString = self.presentStockData_Dummy?.economisURL else {return}
            let websiteURL = URL(string: urlString)
            if let url = websiteURL {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    
    
    
    //CSV 다운, 파싱 함수
    func downloadCSVFile(indexURL: URL) -> [[Date: Double]] {
        var dictionaryArray: [[Date: Double]] = []

        do {
            let csvData = try Data(contentsOf: indexURL)
            guard let csvString = String(data: csvData, encoding: .utf8) else {return dictionaryArray}

            let lines = csvString.components(separatedBy: "\n")

            let trimmedLines = lines.map { line -> String in
                var trimmedLine = line
                if let commaIndex = line.firstIndex(of: ",") {
                    let startIndex = line.index(after: commaIndex)
                    trimmedLine = String(line[startIndex...])
                }
                return trimmedLine
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"

            for line in trimmedLines[1...] {
                let temp = line.components(separatedBy: ",")
                let fields = temp.map { $0.replacingOccurrences(of: "\r", with: "") }

                if let dateString = fields.first, let valueString = fields.last,
                   let date = dateFormatter.date(from: dateString),
                   let value = Double(valueString) {
                    let dictionary: [Date: Double] = [date: value]
                    dictionaryArray.append(dictionary)
                }
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
        return dictionaryArray
    }
    
    //CSV 파싱 함수
    func parseCSVFile(datasetName: String) -> [[Date: Double]] {
        var dictionaryArray: [[Date: Double]] = []

        guard let path = Bundle.main.path(forResource: datasetName, ofType: "csv") else {
            return dictionaryArray
        }

        do {
            let csvString = try String(contentsOfFile: path, encoding: .utf8)
            let lines = csvString.components(separatedBy: "\n")

            let trimmedLines = lines.map { line -> String in
                var trimmedLine = line
                if let commaIndex = line.firstIndex(of: ",") {
                    let startIndex = line.index(after: commaIndex)
                    trimmedLine = String(line[startIndex...])
                }
                return trimmedLine
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"

            for line in trimmedLines[1...] {
                let temp = line.components(separatedBy: ",")
                let fields = temp.map { $0.replacingOccurrences(of: "\r", with: "") }

                if let dateString = fields.first, let valueString = fields.last,
                   let date = dateFormatter.date(from: dateString),
                   let value = Double(valueString) {
                    let dictionary: [Date: Double] = [date: value]
                    dictionaryArray.append(dictionary)
                }
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
        return dictionaryArray
    }
    
    //변동률 계산 함수
    func changeRate(today: Double, yesterDay: Double) -> Double{
        return (((today - yesterDay)/yesterDay)*100).rounded() / 10
    }
    //주식 변동율 = ((현재 가격 – 이전 가격) / 이전 가격) x 100
    
    //showAlert
    func showAlert(title: String, message: String? = nil) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
           alertController.addAction(okAction)
           present(alertController, animated: true, completion: nil)
       }
    
    
}



