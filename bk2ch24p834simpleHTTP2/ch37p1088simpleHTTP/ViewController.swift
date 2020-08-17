

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet var iv : UIImageView!
    
    @IBAction func doSimpleHTTP (_ sender: Any) {
        self.iv.image = nil
        let s = "https://www.apeth.net/matt/images/phoenixnewest.jpg"
        let url = URL(string:s)!
        let session = URLSession.shared
        let task = session.dataTask(with:url) { data, resp, err in
            print("here")
            guard err == nil else {
                print(err as Any)
                return
            }
            let status = (resp as? HTTPURLResponse)?.statusCode
            print("response status: \(status as Any)")
            guard status == 200 else {
                print(status as Any)
                return
            }
            if let d = data {
                let im = UIImage(data:d)
                DispatchQueue.main.async {
                    self.iv.image = im
                    print("done")
                }
            }
        }
        // just demonstrating syntax
        task.priority = URLSessionTask.defaultPriority
        task.resume()
    }
    
    var pipeline : AnyCancellable?
    @IBAction func doCombineNetworking(_ sender: Any) {
        let s = "https://www.apeth.net/matt/images/phoenixnewest.jpg"
        let url = URL(string:s)!
        let session = URLSession.shared
        let pipeline = session.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage? in
                if (response as? HTTPURLResponse)?.statusCode != 200 {
                    throw NSError(domain: "wrong status", code: 0)
                }
                return UIImage(data:data)
            }.receive(on: DispatchQueue.main)
            .sink { comp in
                if case let .failure(err) = comp {
                    print(err)
                }
            } receiveValue: { im in
                print("here's your image")
                self.iv.image = im
            }
        self.pipeline = pipeline
    }
}
