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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set Delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let categoryUrl = createCategoryUrl(){
            //Print the URL to console
            print(categoryUrl)
            //Call the fetchRecipes method using the constructed URL
            fetchCategories(from: categoryUrl)
        }
    }
        

    func setLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.5))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets.trailing = 2
            item.contentInsets.leading = 2

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            section.orthogonalScrollingBehavior = .paging

            return section
        }
    }
}


//MARK: - CollectionView Methods
extension HomeViewController: UICollectionViewDelegate {
    
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
                        cell.categoryImage.layer.cornerRadius = 8
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
    func fetchCategories(from url: URL){
        //Created a suspended task that will execute a closure upon start
        let categoryTask = URLSession.shared.dataTask(with: url){
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
                    
                    //Try and decode someData into array of Recipes using Recipe template
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
        categoryTask.resume()
    }
}

