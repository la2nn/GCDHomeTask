//
//  NetworkService.swift
//  Puzzles
//
//  Created by Leonid Serebryanyy on 18.11.2019.
//  Copyright © 2019 Leonid Serebryanyy. All rights reserved.
//

import Foundation
import UIKit


class NetworkService {
	
	let session: URLSession
	
	private var queue = DispatchQueue(label: "com.sber.puzzless", qos: .default, attributes: .concurrent)

	
	init() {
		session = URLSession(configuration: .default)
	}
	
	
	// MARK:- Первое задание
	
	///  Вот здесь должны загружаться 4 картинки и совмещаться в одну.
	///  Для выполнения этой задачи вам можно изменять только этот метод.
	///  Метод, соединяющий картинки в одну, уже написан (вызывается в конце).
	///  Ответ передайте в completion.
	///  Помните, что надо сделать так, чтобы метод работал как можно быстрее.
	public func loadPuzzle(completion: @escaping (Result<UIImage, Error>) -> ()) {
		// это адреса картинок. они работающие, всё ок!
		let firstURL = URL(string: "https://www.pinclipart.com/picdir/middle/41-411243_smirc-thumbsup-svg-thumbs-up-clipart.png")!
		let secondURL = URL(string: "https://i.pinimg.com/236x/ad/4f/2f/ad4f2ff30f67b19ae84094c40b11e706.jpg")!
		let thirdURL = URL(string: "https://avatars.mds.yandex.net/get-pdb/1943918/19d5e137-6f40-439a-bf0f-1f695ff1e8f6/s375")!
		let fourthURL = URL(string: "https://tse2.mm.bing.net/th?id=OIP.dDgMYPzz9pYcwn14aKZPMgHaJC&pid=15.1")!
		let urls = [firstURL, secondURL, thirdURL, fourthURL]
        
		// в этот массив запишите итоговые картинки
		var results = [UIImage]()
        
        let loadingGroup = DispatchGroup()
        
        for imageUrl in urls {
            loadingGroup.enter()
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                guard let data = data, let image = UIImage(data: data) else { return }
                results.append(image)
                loadingGroup.leave()
            }.resume()
        }
        
        loadingGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                if let merged = ImagesServices.image(byCombining: results) {
                    completion(.success(merged))
                }
            }
        }
    }
    
	
	// MARK:- Второе задание
	
	
	///  Здесь задание такое:
	///  У вас есть ключ keyURL, по которому спрятан клад.
	///  Верните картинку с этим кладом в completion
    public func loadQuiz(completion: @escaping(Result<UIImage, Error>) -> ()) {
        let keyURL = URL(string: "https://sberschool-c264c.firebaseio.com/enigma.json?avvrdd_token=AIzaSyDqbtGbRFETl2NjHgdxeOGj6UyS3bDiO-Y")!
        
        URLSession.shared.dataTask(with: keyURL) { (data, response, error) in
            guard let data = data, let result = try? JSONDecoder().decode(URL.self, from: data) else { return }
                URLSession.shared.dataTask(with: result) { (data, response, error) in
                    if let data = data, let image = UIImage(data: data) {
                        completion(.success(image))
                    }
                }.resume()
        }.resume()
        
    }

}
