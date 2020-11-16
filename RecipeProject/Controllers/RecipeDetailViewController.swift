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
    var removeInstructionIds = false

    //MARK: - Outlets
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var recipeTitle: UILabel!
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var ingredientsList: UILabel!
    @IBOutlet var measuresList: UILabel!
    @IBOutlet var instructionsTable: UITableView!
    
    
    //MARK: - Actions
    @IBAction func videoClicked(_ sender: Any) {
        playVideo(youtubeLink: videoURL)
    }
    
    @IBAction func favouritesClicked(_ sender: UIButton) {
        // Unwrap the recipeId
        if let recipeID = recipeId {
            if let file = filename {
            
            do {
                    //If the recipe isn't already favourited
                    if !favouriteRecipes.contains(recipeID) {
                        // Add the recipeId the array
                        favouriteRecipes.append(recipeID)
                        // Write each recipe in the array to the file
                        var favourites = ""
                        for recipe in favouriteRecipes {
                            favourites += "\(recipe)\n"
                        }
                        
                        try favourites.write(to: file, atomically: true, encoding: String.Encoding.utf8)
                        favouriteButton.isSelected = true
                        
                    } else if favouriteRecipes.contains(recipeID) {
                        // Recipe is already favourited so we need to unfavourite it
                        if let index = favouriteRecipes.firstIndex(of: recipeID) {
                            // Remove the recipe ID from the array
                            favouriteRecipes.remove(at: index)
                        }
                        // If nothing to remove
                        if favouriteRecipes.isEmpty {
                            // Create an empty string to write to the file
                            let emptyStr = ""
                            // Empty out the file with the string
                            try? emptyStr.write(to: file, atomically: true, encoding: String.Encoding.utf8)
                        } else {
                            // Create favourites string to build onto
                            var favourites = ""
                            // Loop through our favourites
                            for recipe in favouriteRecipes {
                                // adding the favourite to the string
                                favourites += "\(recipe)\n"
                            }
                            // Check if we have no favourites
                            if !favourites.isEmpty {
                                // If we have some favourites go ahead and write the favourites to our file
                                try? favourites.write(to: file, atomically: true, encoding: String.Encoding.utf8)
                            }
                            favouriteButton.isSelected = false
                            
                        }
                    }
        } catch {
            print(error.localizedDescription, error)
        }
    }
}
}
    
            
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create our url to fetch from
        if let recipeUrl = createRecipeUrl(){
            //Print the URL to console for debug reasons
            print(recipeUrl)
            //Call the fetchRecipes method using the constructed URL
            fetchRecipe(from: recipeUrl)
            
            
        }
        
        // Create array to hold our favourited recipes
        favouriteRecipes = [String]()
        // Grab our documents directory appending our desired file name to the end
        filename = getDocumentsDirectory().appendingPathComponent("favourites.txt")
        
        
        if let favs = try? String(contentsOf: filename!) {
            // Set our current favourites to the file contents seperated by '\n'
            favouriteRecipes = favs.components(separatedBy: "\n")
        }
        
        

        
        // Make it so that the image will fill the size of the button
        favouriteButton.contentVerticalAlignment = .fill
        favouriteButton.contentHorizontalAlignment = .fill
        favouriteButton.layer.cornerRadius = 15
        // Add insets to add outside edge to the image
        favouriteButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        // Round our buttons corners
        videoButton.layer.cornerRadius = 15
        categoryButton.layer.cornerRadius = 10
        
        // Unwrap the recipeId optional
        if let recipeID = recipeId {
            // if recipe is already favourited
            if favouriteRecipes.contains(recipeID) {
                // set button .isSelected state to true
                favouriteButton.isSelected = true
            } else {
                // Otherwise deselect the button
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
                        
                    // Perform actions on main thread
                    DispatchQueue.main.async {
                        // If recipe exists
                        if let recipe = self.recipe {
                            // Get the image
                            if let imageString = recipe.strMealThumb {
                                    // Create url from imageString
                                    if let imageURL = URL(string: imageString) {
                                        // try and get the data from the imageURL
                                        if let data = try? Data(contentsOf: imageURL) {
                                            // set the recipe title image
                                            self.recipeImage.image = UIImage(data: data)
                                            self.recipeTitle.text = recipe.strMeal
                                            
                                            // show the favourites button
                                            self.favouriteButton.isHidden = false
                                        }
                                    }
                            }
                                
                            if let recipeCategory = recipe.strCategory {
                                self.categoryButton.setTitle(recipeCategory, for: .normal)
                                self.category = recipeCategory
                            }
                                
                                //Try and get the youtube link from the current recipe
                            if let youtubeVideo = recipe.strYoutube {
                                    if youtubeVideo != "" {
                                        // Set the url to the recipecs video
                                        print(youtubeVideo)
                                        self.videoURL = youtubeVideo
                                    } else {
                                        //Hide the button
                                        self.videoButton.isHidden = true
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

                                // Create a counter for updating our dictionary
                                var counter = 0
                                // Loop through the measurements
                                for measure in measures {
                                    // Unwrap each measurement
                                    if let measurement = measure {
                                        // Make sure we dont go out of bounds
                                        if counter <= ingredients.count-1 {
                                            //Update the dictionary placing the measurement for each ingredient
                                            ingredientsAndMeasurements.updateValue(measurement, forKey: ingredients[counter]!)
                                            // Increase our counter
                                            counter += 1
                                        }
                                    }
                                    
                                }
                                
                                // Loop through the dictionary and append each measure/ingredient to their labels
                                for (ingredient, measure) in ingredientsAndMeasurements {
                                    self.measuresList.text! += "\(measure) -\n"
                                    self.ingredientsList.text! += " \(ingredient)\n"
                                }
                            
                            
                            // Unwrap the recipe
                            if let recipe = self.recipe {
                                // Unwrap the instructions
                                if let instructions = recipe.strInstructions {
                                    // Create placeholder instructions string array to seperate the instructions
                                    var tempInstructions = [String]()
                                    // If recipe uses '\n' to seperate their instructions
                                    if instructions.contains("\n") {
                                        // Set the temp instructions to be seperated by '\n'
                                        tempInstructions = instructions.components(separatedBy: "\n")
                                    } else {
                                        // If not just do it with sentences.
                                        tempInstructions = instructions.components(separatedBy: ". ")
                                    }
                                    // Do a final pass on the array making sure to remove extra '\r' characters
                                    let filteredInstructions = tempInstructions.filter({ $0 != "\r" })
                                    
                                    // Loop through our filtered instrucions
                                    for instruction in filteredInstructions {
                                        if instruction.trimmingCharacters(in: .whitespacesAndNewlines).count > 4 {
                                            // If instructions is long enough to warrant being an instruction
                                            // Add it to the list
                                            self.instructionsList.append(instruction)
                                        } else {
                                            print("Invalid instruciton. Not added!")
                                        }
                                        
                                    }
                                }
                            }
                            
                            // Reload our tableView to display newest info
                            self.instructionsTable.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionsCell") as! InstructionCell
        
        let instruction = instructionsList[indexPath.row]
        // Make instruciton non selectable
        cell.selectionStyle = .none
        // Set the instruction and its id
        cell.instructionTitle?.text = instruction
        cell.instructionId.text = "\(indexPath.row + 1)"
        
        return cell
    }
    
}
