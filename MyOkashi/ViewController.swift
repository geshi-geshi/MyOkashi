import UIKit

class ViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        //SearchBarのdelegate通知先を設定
        searchText.delegate = self
        searchText.placeholder = "お菓子の名前を入力して下さい"
        // Table ViewのdataSourceを設定
        tableView.dataSource = self
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // お菓子のリスト(タプル配列)
    var okashiList : [(maker:String, name:String, price:String, comment:String, link:URL, image:URL)] = []
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
                
//                print(json)
                
                // お菓子の取得ができているかの確認
                if let items = json.item {
                    // お菓子のリストを初期化
                    self.okashiList.removeAll()
                    // 取得しているお菓子の数だけ処理
                    for item in items {
                        // それぞれをアンラップ
                        if let maker = item.maker, let name = item.name, let price = item.price, let comment = item.comment, let link = item.url, let image = item.image {
                            // 一つのお菓子をタプルでまとめて管理
                            let okashi = (maker, name, price, comment, link, image)
                            // お菓子の配列へ追加
                            self.okashiList.append(okashi)
                        }
                    }
                    // Table Viewを更新する
                    self.tableView.reloadData()
                    
                    if let okashidbg = self.okashiList.first {
                        print("-----------------------")
                        print("okashiList[0] = \(okashidbg)")
                    }
                }
            } catch {
                print("エラーです!!!!")
            }
        })
        
        // ダウンロード開始(dataTaskで登録されたるリクエストのタスクが実行される)
        task.resume()
    }
    
    // Cellの総数を返すdatasourceメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // お菓子リストの総数
        return okashiList.count
    }
    
    // Cellに値を設定するdatasourceメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 表示を行うCellオブジェクトを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        // お菓子のタイトル設定
        cell.textLabel?.text = okashiList[indexPath.row].name
        // お菓子画像を取得
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image) {
            // 正常に取得できた場合はUIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        
        // 設定済みのCellオブジェクトを画面に反映
        return cell
        
    }
}
