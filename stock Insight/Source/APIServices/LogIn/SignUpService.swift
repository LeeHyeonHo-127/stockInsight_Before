import Foundation
import Alamofire

struct SignUpService{
    static let shared = SignUpService()
    
    //회원가입
    func singUp(email: String,
                password: String,
                name: String,
                completion: @escaping (NetworkResult<Any>) -> (Void) ) {
        
        
        let url = APIConstants.signUpURL
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let body: Parameters = [
            "user_id" : email,
            "pw" : password,
            "name" : name
        ]
        
        let dataRequest = AF.request(url,
                                     method: .post,
                                     parameters: body,
                                     encoding: URLEncoding.default,
                                     headers: header)
        dataRequest.responseData(completionHandler: {(response) in
            switch response.result{
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    return
                }
                guard let data = response.value else {
                    return
                }
                completion(doSignUp(status: statusCode, data: data))
            case .failure(let error):
                print(error)
                completion(.networkFail)
            }
        })
    }
    
    //회원가입 여부 확인
    private func doSignUp(status: Int, data: Data) -> NetworkResult<Any>{
        let decoder = JSONDecoder()
        guard let decodedData = try? decoder.decode(User.self, from: data) else {
            return .pathErr
        }
        
        switch status {
        case 200:
            // 회원가입 성공
            return .success(decodedData)
        case 409:
            // 중복된 이메일
            return .requestErr(decodedData)
        case 400:
            // 잘못된 파라미터
            return .wrongParameter
        default:
            return .networkFail
        }
    }
}
