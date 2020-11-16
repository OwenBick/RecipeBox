//
//  CategoryViewController.swift
//  RecipeProject
//
//  Created by Owen Bick on 11/1/20.
//

import UIKit

class CategoryViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    
    //MARK: - Properties
    var allMeals = [Recipe]()
    var categoryName: String?
    var recipe: String?
    
    
    //MARK: - ViewDidLoad
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
        if let recipeID = allMeals[indexPath.row].idMeal {
            recipe = recipeID
        }
        
        performSegue(withIdentifier: "categoryToRecipeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get destination view controller
        if let vc = segue.destination as? RecipeDetailViewController {
            
            // Set the recipeId
            vc.recipeId = recipe ?? "52772"
            
        }
    }
}

//MARK: - CollectionView Methods
extension CategoryViewController: UICollectionViewDelegate { }


extension CategoryViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMeals.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        
        let recipe = allMeals[indexPath.row]
            
        if let categoryName = recipe.strMeal {
            cell.recipeName?.text = categoryName
            cell.recipeName?.layer.cornerRadius = 10
        }
        //If the current recipe has an image
        if let imageString = recipe.strMealThumb {
            //If the string can be converted into a URL
            if let imageUrl = URL(string: imageString) {
                //Try and see if the URL can be converted into Data
                if let data = try? Data(contentsOf: imageUrl) {
                    //See if that Data can create a UIImage
                    if let image = UIImage(data: data) {
                        //If so set the recipe image to the UIImage you just created
                        cell.recipeImage.image = image
                        cell.recipeImage.layer.cornerRadius = 8
                    } else {
                        //If not set the recipe image to the '' SF Symbol
                        cell.recipeImage.image = UIImage(systemName: "questionmark.square")
                    }
                }
            }
        }
        return cell
    }
    
    //MARK: - Creating URL
    func createCategoryUrl() -> URL? {
        // Explictly unwrap because categoryName is set in the HomeViewController during segue
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(categoryName!)"
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
                        
                        
                        //Try and decode someData into array of Recipes using Recipe template
                        let downloadedResults = try jsonDecoder.decode(Recipes.self, from: someData)
                            
                        if downloadedResults.meals.isEmpty {
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
                            self.allMeals = downloadedResults.meals
                                
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


