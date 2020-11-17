//
//  HomeViewController.swift
//  RecipeProject
//
//  Created by Owen Bick on 10/31/20.
//

import UIKit

class HomeViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    
    //MARK: - Properties
    var allCategories = [Category]()
    var category: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set Delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        self.title = "Recipe Box"
        if let categoryUrl = createCategoryUrl(){
            //Print the URL to console
            print(categoryUrl)
            //Call the fetchRecipes method using the constructed URL
            fetchResults(from: categoryUrl)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let categoryName = allCategories[indexPath.row].strCategory {
            category = categoryName
        }
        
        performSegue(withIdentifier: "homeToCategorySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CategoryViewController {
            if let selectedCategory = category {
                vc.categoryName = selectedCategory
            }
        }
    }
}

//MARK: - CollectionView Methods
extension HomeViewController: UICollectionViewDelegate { }

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        switch screenWidth {
        case 414:
            return CGSize(width: (screenWidth - 10)/2, height: (screenWidth - 10)/2)
        case let width where width > 414:
            return CGSize(width: (screenWidth - 15)/3, height: (screenWidth - 15)/3)
        default:
            return CGSize(width: screenWidth, height: screenWidth)
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCategories.count
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = allCategories[indexPath.row]
            
        if let categoryName = category.strCategory {
            cell.categoryName?.text = categoryName
            cell.categoryName?.layer.cornerRadius = 10
        }
        //If the current recipe has an image
        if let imageString = category.strCategoryThumb {
            //If the string can be converted into a URL
            if let imageUrl = URL(string: imageString) {
                //Try and see if the URL can be converted into Data
                if let data = try? Data(contentsOf: imageUrl) {
                    //See if that Data can create a UIImage
                    if let image = UIImage(data: data) {
                        //If so set the recipe image to the UIImage you just created
                        cell.categoryImage.image = image
                    } else {
                        //If not set the recipe image to the '' SF Symbol
                        cell.categoryImage.image = UIImage(systemName: "questionmark.square")
                    }
                }
            }
        }
        return cell
    }
    
    //MARK: - Creating URL
    func createCategoryUrl() -> URL? {
        let urlString = "https://www.themealdb.com/api/json/v1/1/categories.php"
        //Return a URL using the string value
        return URL(string: urlString)
    }
    
    //MARK: - Fetch Results
    func fetchResults(from url: URL){
            //Created a suspended task that will execute a closure upon start
            let fetchTask = URLSession.shared.dataTask(with: url){
                data, response, error in
                
                //If the request fails
                if let anError = error {
                    print("There was an error requesting data : \(anError.localizedDescription)")
                } else { //Succesfully made request
                    do {
                        //Check for data if not stop execution
                        guard let someData = data else {
                            return
                        }
                        
                        //Create JSONDecoder
                        let jsonDecoder = JSONDecoder()
                        
                        
                        //Try and decode someData into array of Categories using Category template
                        let downloadedResults = try jsonDecoder.decode(Categories.self, from: someData)
                            
                        if downloadedResults.categories.isEmpty {
                            DispatchQueue.main.async {
                                //Create a UIAlertController and set the title, and alert style
                                let alert = UIAlertController(title: "No Results Found", message: nil, preferredStyle: .alert)
                                    
                                //Add an action for the user to select. in this case a default action with the title "OK"
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                                    
                                    
                                //Present the alert to the user
                                self.present(alert, animated: true, completion: nil)
                                self.collectionView.reloadData()
                            }
                        } else {
                            //set our allCategories array to the downloaded results
                            self.allCategories = downloadedResults.categories
                                
                        }
                    } catch let error {
                        //Print the description for the error
                        print("Problem decoding: \(error.localizedDescription)")
                        //Print the error
                        print(error)
                    }
                    
                    //Use main thread to perform updates
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
            //Start the task
            fetchTask.resume()
    }
}
