//
//  RecipeDetailViewController.swift
//  RecipeProject
//
//  Created by Owen Bick on 11/4/20.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    //MARK: - Properties
    var recipeId: String?
    var recipe = [RecipeDetail]()

    @IBOutlet var recipeImage: UIImageView!
    
    @IBOutlet var recipeTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let recipeUrl = createRecipeUrl(){
            //Print the URL to console
            print(recipeUrl)
            //Call the fetchRecipes method using the constructed URL
            fetchRecipe(from: recipeUrl)
        }
    }
    
    //MARK: - Creating URL
    func createRecipeUrl() -> URL? {
        let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(recipeId ?? "52773")"
        //Return a URL using the string value
        return URL(string: urlString)
    }
    
    //MARK: - Fetch Recipe
    func fetchRecipe(from url: URL){
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
                        let downloadedResults = try jsonDecoder.decode(RecipeDetails.self, from: someData)
                         
                        if downloadedResults.meals.isEmpty {
                            //Create a UIAlertController and set the title, and alert style
                            let alert = UIAlertController(title: "No Results Found", message: nil, preferredStyle: .alert)
                                
                            //Add an action for the user to select. in this case a default action with the title "OK"
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                                
                                
                            //Present the alert to the user
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            self.recipe = downloadedResults.meals
                            if let imageString = self.recipe[0].strMealThumb {
                                if let imageURL = URL(string: imageString) {
                                    if let data = try? Data(contentsOf: imageURL) {
                                        DispatchQueue.main.async {
                                            self.recipeImage.image = UIImage(data: data)
                                            self.recipeTitle.text = self.recipe[0].strMeal
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                    } catch let error {
                        //Print the description for the error
                        print("Problem decoding: \(error.localizedDescription)")
                        //Print the error
                        print(error)
                    }
                }
            }
            //Start the task
            fetchTask.resume()
    }
    

}
