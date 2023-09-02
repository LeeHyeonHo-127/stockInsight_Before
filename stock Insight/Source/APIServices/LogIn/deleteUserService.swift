import Foundation
import Alamofire

struct DeleteUserService{
    static let shared = DeleteUserService()
    
    //유저 삭제
    func deleteUser(username: String,
                        Password: String,
                        quiz: String,
                        answer: String,
                        completion: @escaping (NetworkResult<Any>) -> (Void) ) {
        
        let url = APIConstants.deleteUserURL
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let body: Parameters = [
            "username" : username,
            "pw" : Password,
            "resetQuestion" : quiz,
            "resetAnswer": answer
        ]
        
        let dataRequest = AF.request(url,
                                     method: .post,
                                     parameters: body,
                                     encoding: JSONEncoding.default,
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
                completion(doDeleteUser(status: statusCode, data: data))
            case .failure(let error):
                print(error)
                completion(.networkFail)
            }
        })
    }
    
    //회원가입 여부 확인
    private func doDeleteUser(status: Int, data: Data) -> NetworkResult<Any>{
        let success = "성공"
        let error = "중복된 이메일"
        
        switch status {
        case 200:
            // 비밀번호 수정 완요
            return .success(success)
        case 409:
            // 중복된 이메일
            return .requestErr(error)
        case 400:
            // 잘못된 파라미터
            return .wrongParameter
        default:
            return .networkFail
        }
    }
}
