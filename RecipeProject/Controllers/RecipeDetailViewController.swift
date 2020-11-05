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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let recipeUrl = createRecipeUrl(){
            //Print the URL to console
            print(recipeUrl)
            //Call the fetchRecipes method using the constructed URL
            fetchRecipe(from: recipeUrl)
        }
        
        //recipeImage.image = UIImage(data: try! Data(contentsOf: URL(string: recipe[0].strMealThumb!)!))
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
                         print(downloadedResults)
                        if downloadedResults.recipeDetails.isEmpty {
                            DispatchQueue.main.async {
                                fatalError("Error downloading recipe")
                            }
                        } else {
                            //set our recipe outlets
                            print(downloadedResults)
                            self.recipe = downloadedResults.recipeDetails
                            
                                
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
