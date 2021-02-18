//
//  ViewController.swift
//  lecture8
//
//  Created by admin on 08.02.2021.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var feelsLikeTemp: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var myData: Model?
    var city = "Nur-Sultan"
    private var decoder: JSONDecoder = JSONDecoder()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        fetchData()
    }
    
    
    func updateUI(){
        cityName.text = city
        temp.text = "\(String(myData?.current.temp ?? 0.0)) °C"
        feelsLikeTemp.text = "\(String(myData?.current.feels_like ?? 0.0)) °C"
        desc.text = myData?.current.weather?[0].description
    }
    
    func fetchData(){
        let url = Constants.host + "?lat=\(Constants.lat)&lon=\(Constants.long)&exclude=\(Constants.exclude)&appid=\(Constants.apiKey)&units=metric"
        AF.request(url).responseJSON { (response) in
            switch response.result{
            case .success(_):
                guard let data = response.data else { return }
                do{
                    let answer = try self.decoder.decode(Model.self, from: data)
                    self.myData = answer
                    self.updateUI()
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }catch{
                    print("Parsing error")
                }
                self.updateUI()
            case .failure(let err):
                print(err.errorDescription ?? "")
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                Constants.lat = "51.15"
                Constants.long = "71.47"
                city = "Nur-Sultan"
            case 1:
                Constants.lat = "43.22"
                Constants.long = "76.85"
                city = "Almaty"
            case 2:
                Constants.lat = "54.87"
                Constants.long = "69.15"
                city = "Petropavlovsk"
            default:
                break
        }
        fetchData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return (myData?.daily.count)!
        return myData?.daily.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let item = myData?.daily[indexPath.row]
        let date = Date(timeIntervalSince1970: TimeInterval(item!.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        cell.dateLabel.text = localDate
        cell.temperatureLabel.text = "\(item?.temp?.day ?? 0) °C"
        cell.feelsLikeLabel.text = "\(item?.feels_like?.day ?? 0) °C"
        cell.descriptionLabel.text = item?.weather?[0].description
        return cell
    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myData?.hourly.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let item = myData?.hourly[indexPath.row]
        let date = Date(timeIntervalSince1970: TimeInterval(item!.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        cell.dateLabel.text = localDate
        cell.temperatureLabel.text = "\(item?.temp ?? 0) °C"
        cell.feelsLikeLabel.text = "\(item?.feels_like ?? 0) °C"
        cell.descriptionLabel.text = item?.weather?[0].description
        return cell
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: 194, height: 194)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
