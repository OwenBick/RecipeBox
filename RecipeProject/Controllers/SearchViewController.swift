////
//  ViewController.swift
//  RecipeProject
//
//  Created by Owen Bick on 10/4/20.
//

import UIKit

class SearchViewController: UIViewController {
    
    //MARK: - Properties
    var allRecipes = [Recipe]()
    var recipeId: String?
    
    //MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Delegates
        searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let recipeID = allRecipes[indexPath.row].idMeal {
            recipeId = recipeID
        }
        
        performSegue(withIdentifier: "recipeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RecipeDetailViewController {
            vc.recipeId = recipeId ?? "52773"
        }
    }
    
}


//MARK: - CollectionView Methods
extension SearchViewController: UICollectionViewDelegate {
    
}


extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allRecipes.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        let recipe = allRecipes[indexPath.row]
        
        if let recipeTitle = recipe.strMeal {
            cell.recipeName?.text = recipeTitle
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
    //Creates a URL from the provided String
    func createRecipeUrl(from  recipe: String) -> URL? {
        //Try and make a new url with the percent encoding characters included
        guard let cleanUrl = recipe.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            //Stop execution and throw error
            fatalError("Can't create url with string: \(recipe)")
        }
        
        var urlString = "https://www.themealdb.com/api/json/v1/1/search.php?s="
        //Append the cleanURL
        urlString = urlString.appending(cleanUrl)
        
        //Return a URL using the string value
        return URL(string: urlString)
    }
    
    //MARK: - Fetch Results
    func fetchRecipes(from url: URL, for searchString: String){
        //Created a suspended task that will execute a closure upon start
        let recipeTask = URLSession.shared.dataTask(with: url){
            data, response, error in
            
            //If the request fails
            if let anError = error {
                print("There was an error requesting data : \(anError.localizedDescription)")
            } else { //Succesfully made request
                do {
                    //Check for data if not stop execution
                    guard let someData = data else {
                        //Clear search bar
                        self.searchBar.text = ""
                        //Create a UIAlertController and set the title, and alert style
                        let alert = UIAlertController(title: "No Results Found", message: nil, preferredStyle: .alert)
                        
                        //Add an action for the user to select. in this case a default action with the title "OK"
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                        
                        
                        //Present the alert to the user
                        self.present(alert, animated: true, completion: nil)
                        self.collectionView.reloadData()
                        return
                    }
                    
                    //Create JSONDecoder
                    let jsonDecoder = JSONDecoder()
                    
                    //Try and decode someData into array of Recipes using Recipe template
                    let downloadedResults = try jsonDecoder.decode(Recipes.self, from: someData)
                    print(downloadedResults.meals.isEmpty)
                    
                    //set our allRecipes array to the downloaded results
                    self.allRecipes = downloadedResults.meals
                    
                } catch let error {
                    // Use the main thread to update
                    DispatchQueue.main.async {
                        //Print the description for the error
                        print("Problem decoding: \(error.localizedDescription)")
                        //Print the error
                        print(error)
                        //Clear search bar
                        self.searchBar.text = ""
                        //Create a UIAlertController and set the title, and alert style
                        let alert = UIAlertController(title: "No Results Found", message: nil, preferredStyle: .alert)
                        
                        //Add an action for the user to select. in this case a default action with the title "OK"
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                        
                        
                        //Present the alert to the user
                        self.present(alert, animated: true, completion: nil)
                        self.collectionView.reloadData()
                    }
                    
                }
            }
        }
        //Start the task
        recipeTask.resume()
    }
}



extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Check to see if searchBar text exists, if not stop execution
        guard let searchText = searchBar.text else { return }
        
        //Try and create URL using createRecipeUrl method
        if let recipeUrl = createRecipeUrl(from: searchText){
            //Print the URL to console
            print(recipeUrl)
            //Call the fetchRecipes method using the constructed URL
            fetchRecipes(from: recipeUrl, for: searchText)
        }
        
        //Dismiss the keyboard
        searchBar.resignFirstResponder()
    }
}
