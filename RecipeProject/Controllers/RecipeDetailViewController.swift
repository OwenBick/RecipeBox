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
    var favouriteRecipes: [String] = []
    var filename = URL(string: "")

    //MARK: - Outlets
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var recipeTitle: UILabel!
    
    //MARK: - Actions
    @IBAction func buttonClicked(_ sender: UIButton) {
        
            // If buttonState isn't .selected when clicked
            if !favouriteButton.isSelected {
                do {
                    // Unwrap the recipeId
                    if let recipeID = recipeId {
                        //If the recipe isn't already favourited
                        if !favouriteRecipes.contains(recipeID) {
                            // Add the recipeId the array
                            favouriteRecipes.append(recipeID)
                            // Write each recipe in the array to the file
                            var favourites = ""
                            for recipe in favouriteRecipes {
                                favourites += "\(recipe)\n"
                            }
                            if let file = filename {
                                try favourites.write(to: file, atomically: true, encoding: String.Encoding.utf8)
                            }
                        }
                    }
                    
                } catch {
                    
                }
                // Add to favourites
                favouriteButton.isSelected = true
                //Create a UIAlertController and set the title, and alert style
                let alert = UIAlertController(title: "Added to Favourites!", message: nil, preferredStyle: .alert)
                    
                //Add an action for the user to select. in this case a default action with the title "OK"
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                    
                    
                //Present the alert to the user
                self.present(alert, animated: true, completion: nil)
                
            } else {
                if favouriteButton.isSelected {
                    do {
                        // Unwrap the optional recipeId
                        if let recipeID = recipeId {
                            // If recipe is favourited
                            if favouriteRecipes.contains(recipeID) {
                                if let index = favouriteRecipes.firstIndex(of: recipeID) {
                                    favouriteRecipes.remove(at: index)
                                }
                                if let file = filename {
                                    // If nothing to remove
                                    if favouriteRecipes.isEmpty {
                                        let emptyStr = ""
                                            
                                        try? emptyStr.write(to: file, atomically: true, encoding: String.Encoding.utf8)
                                    } else {
                                        var favourites = ""
                                        for recipe in favouriteRecipes {
                                            favourites += "\(recipe)\n"
                                        }
                                        if !favourites.isEmpty {
                                            try? favourites.write(to: file, atomically: true, encoding: String.Encoding.utf8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                  }
                    favouriteButton.isSelected = false
                }
            }
        
        
        
    
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        favouriteRecipes = [String]()
        // Set the filename
        filename = getDocumentsDirectory().appendingPathComponent("favourites.txt")
        
        
        if let favs = try? String(contentsOf: filename!) {
            favouriteRecipes = favs.components(separatedBy: "\n")
            print("Inital array: \(favouriteRecipes)")
        }
        
        

        if let recipeUrl = createRecipeUrl(){
            //Print the URL to console
            print(recipeUrl)
            //Call the fetchRecipes method using the constructed URL
            fetchRecipe(from: recipeUrl)
        }
        // Make it so that the image will fill the size of the button
        favouriteButton.contentVerticalAlignment = .fill
        favouriteButton.contentHorizontalAlignment = .fill
        favouriteButton.layer.cornerRadius = 15
        // Add insets to add outside edge to the image
        favouriteButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        // Unwrap the recipeId optional
        if let recipeID = recipeId {
            // Unwrap the favourites
            if favouriteRecipes.contains(recipeID) {
                    // If so set button .isSelected state to true
                    favouriteButton.isSelected = true
                } else {
                    // Otherwise false
                    favouriteButton.isSelected = false
                }
            }
        }
        
        
    
    
    // Retrieve the documents directory
    func getDocumentsDirectory() -> URL {
        // Get the default path URL
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        // Return the URL
        return documentsDirectory
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
