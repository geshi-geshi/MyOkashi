import UIKit

class ViewController: UIViewController,UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //SearchBarのdelegate通知先を設定
        searchText.delegate = self
        
        searchText.placeholder = "お菓子の名前を入力して下さい"
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // 検索ボタンをクリックした時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //キーボードを閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            
            // デバックエリアに出力
            print(searchWord)
            
            // 入力されていたら、お菓子を検索
            searchOkashi(keyword: searchWord)
        }
    }
    
    // Jsonのitem内のデータ構造
    struct ItemJson: Codable {
        
        let name: String?
        let maker: String?
        let price: String?
        let comment: String?
        
        let url: URL?
        let image: URL?
    }
    
    //Jsonのデータ構造
    struct ResultJson: Codable {
        
        // 複数要素
        let item:[ItemJson]?
    }
    
    // keyword :String 検索したいワード
    func searchOkashi(keyword : String) {
        // お菓子の検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return
        }
        
        // リクエストURLの組み立て
        guard let req_url = URL( string: "http://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        
        print(req_url)
        
        // リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        // データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            
            // セッションを終了
            session.finishTasksAndInvalidate()
            
            do {
                let decoder = JSONDecoder()
                // 受け取ったJSONデータをパース（解析）して格納
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                print(json)
            } catch {
                print("エラーです!!!!")
            }
        })
        
        // ダウンロード開始(dataTaskで登録されたるリクエストのタスクが実行される)
        task.resume()
    }
}
