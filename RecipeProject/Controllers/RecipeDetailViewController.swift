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
    var recipe: RecipeDetail?
    var favouriteRecipes: [String] = []
    var filename = URL(string: "")
    var videoURL = ""
    var category: String?
    var instructionsList = [String]()

    //MARK: - Outlets
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var recipeTitle: UILabel!
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var ingredientsList: UILabel!
    @IBOutlet var measuresList: UILabel!
    
    @IBOutlet var instructionsTable: UITableView!
    //    //MARK: - Actions
//    @IBAction func categoryClicked(_ sender: Any) {
//        performSegue(withIdentifier: "categorySegue", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? CategoryViewController {
//            if let selectedCategory = category {
//                vc.categoryName = selectedCategory
//            }
//        }
//    }
    
    @IBAction func videoClicked(_ sender: Any) {
        playVideo(youtubeLink: videoURL)
    }
    
    @IBAction func favouritesClicked(_ sender: UIButton) {
        
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
                // change the button state so the user knows the recipe has been added
                favouriteButton.isSelected = true
                
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
        
        // Set the delegate and data source
        instructionsTable.delegate = self
        instructionsTable.dataSource = self
        
        if let recipeUrl = createRecipeUrl(){
            //Print the URL to console
            print(recipeUrl)
            //Call the fetchRecipes method using the constructed URL
            fetchRecipe(from: recipeUrl)
            
            
        }
        
        favouriteRecipes = [String]()
        // Set the filename
        filename = getDocumentsDirectory().appendingPathComponent("favourites.txt")
        
        
        if let favs = try? String(contentsOf: filename!) {
            favouriteRecipes = favs.components(separatedBy: "\n")
            print("Inital array: \(favouriteRecipes)")
        }
        
        

        
        // Make it so that the image will fill the size of the button
        favouriteButton.contentVerticalAlignment = .fill
        favouriteButton.contentHorizontalAlignment = .fill
        favouriteButton.layer.cornerRadius = 15
        // Add insets to add outside edge to the image
        favouriteButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        videoButton.layer.cornerRadius = 15
        categoryButton.layer.cornerRadius = 10
        
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
        
    
    // Play a youtube video using safari
    func playVideo(youtubeLink: String) {
        // If we can unwrap the link 
        if let youtubeURL = URL(string: youtubeLink) {
            // Use safari
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
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
                } else { // Succesfully made request
                    do {
                        // Check for data if not stop execution
                        guard let someData = data else {
                            return
                        }
                        
                        // Create JSONDecoder
                        let jsonDecoder = JSONDecoder()
                        
                        
                        // Try and decode someData into array of Recipes using Recipe template
                        let downloadedResults = try jsonDecoder.decode(RecipeDetails.self, from: someData)
                        
                        
                        print(downloadedResults.meals[0])
                        // Set the recipeDetail object to the downloaded results
                        self.recipe = downloadedResults.meals[0]
                        
                            
                       
                        if let recipe = self.recipe {
                            if let imageString = recipe.strMealThumb {
                                    if let imageURL = URL(string: imageString) {
                                        if let data = try? Data(contentsOf: imageURL) {
                                            DispatchQueue.main.async {
                                                self.recipeImage.image = UIImage(data: data)
                                                self.recipeTitle.text = recipe.strMeal
                                            
                                                self.favouriteButton.isHidden = false
                                            }
                                        }
                                    }
                            }
                                
                            if let recipeCategory = recipe.strCategory {
                                DispatchQueue.main.async {
                                    self.categoryButton.setTitle(recipeCategory, for: .normal)
                                    self.category = recipeCategory
                                }
                            }
                                
                                //Try and get the youtube link from the current recipe
                            if let youtubeVideo = recipe.strYoutube {
                                    if youtubeVideo != "" {
                                        // Set the url to the recipecs video
                                        print(youtubeVideo)
                                        self.videoURL = youtubeVideo
                                    } else {
                                        //Hide the button
                                        DispatchQueue.main.async {
                                        self.videoButton.isHidden = true
                                    }
                                }
                            }
                            

                           
                            // Create a dictionary to hold our measures and ingredients
                            var ingredientsAndMeasurements =  [String : String]()
                           
                            // Create an array of our ingredients
                            var ingredients = [recipe.strIngredient1, recipe.strIngredient2, recipe.strIngredient3, recipe.strIngredient4, recipe.strIngredient5, recipe.strIngredient6, recipe.strIngredient7, recipe.strIngredient8, recipe.strIngredient9, recipe.strIngredient10, recipe.strIngredient11, recipe.strIngredient12, recipe.strIngredient13, recipe.strIngredient14, recipe.strIngredient15, recipe.strIngredient16, recipe.strIngredient17, recipe.strIngredient18, recipe.strIngredient19, recipe.strIngredient20]
                            
                            // Filter out empty strings
                            ingredients = ingredients.filter({ $0 != "" })

                            // Create an array of our measurements
                            var measures = [recipe.strMeasure1, recipe.strMeasure2, recipe.strMeasure3, recipe.strMeasure4, recipe.strMeasure5, recipe.strMeasure6, recipe.strMeasure7, recipe.strMeasure8, recipe.strMeasure9, recipe.strMeasure10, recipe.strMeasure11, recipe.strMeasure12, recipe.strMeasure13, recipe.strMeasure14, recipe.strMeasure15, recipe.strMeasure16, recipe.strMeasure17, recipe.strMeasure18, recipe.strMeasure19, recipe.strMeasure20]

                                // Filter out empty strings
                                measures = measures.filter({ $0 != "" })

                                var counter = 0
                                for measure in measures {
                                    if counter <= ingredients.count-1 {
                                        
                                        print(ingredients.count)
                                        ingredientsAndMeasurements.updateValue(measure!, forKey: ingredients[counter]!)
                                        print(ingredientsAndMeasurements)
                                        counter += 1
                                    }
                                }
                                
                            
                            
                            
                            
                                for (ingredient, measure) in ingredientsAndMeasurements {
                                    DispatchQueue.main.async {
                                        print("Ingredient: \(ingredient)\n measure: \(measure)")
                                        self.measuresList.text! += "\(measure) -\n"
                                        self.ingredientsList.text! += " \(ingredient)\n"
                                    }
                                }
                            
                            
                            
                            if let instructions = recipe.strInstructions {
                                self.instructionsList = instructions.components(separatedBy: "\n")
                                print(self.instructionsList[0])
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

//MARK: - TableView Extensions
extension RecipeDetailViewController: UITableViewDelegate {
    
}

extension RecipeDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionCell", for: indexPath) as! InstructionCell
        
        let instruction = instructionsList[indexPath.row]
        
        cell.textLabel?.text = instruction
        
        return cell
    }
    
    
}
