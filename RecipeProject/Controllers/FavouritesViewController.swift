//
//  FavouritesViewController.swift
//  RecipeProject
//
//  Created by Owen Bick on 10/31/20.
//

import UIKit

class FavouritesViewController: UITableViewController {
    //MARK: - Properties
    var allRecipes = [String]()
    var favouriteRecipes: [Recipe] = []
    var recipe: String?
    
    //MARK: - Actions
    @IBAction func refreshTable(_ sender: UIBarButtonItem) {
        
        // Create a UIAlertController and set the title, and alert style
        let alert = UIAlertController(title: "Delete all recipes from your favorites?", message: nil, preferredStyle: .alert)
            
        // Add an action for the user to select. in this case a default action with the title "OK"
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Default action"), style: .destructive))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
            self.favouriteRecipes.removeAll()
            let filename = self.getDocumentsDirectory().appendingPathComponent("favourites.txt")
            
            // If no favourites
            if self.favouriteRecipes.isEmpty {
                // Create an empty string
                let emptyStr = ""
                    
                // Write it to the file
                try? emptyStr.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                
                // Reload the tableView
                self.tableView.reloadData()
            }
        }))
            
            
        // Present the alert to the user
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
         
    override func viewWillAppear(_ animated: Bool) {
        loadFavourites()
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Reload the tableView
        tableView.reloadData()
        
        // Set navItem title
        navigationItem.title = "Favourites"
        
        
           
        
        if allRecipes.isEmpty {
            print("Empty")
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
    
    func loadFavourites() {
        let fileUrl = getDocumentsDirectory().appendingPathComponent("favourites.txt")
        
            if let favouritedRecipes = try? String(contentsOf: fileUrl) {
                allRecipes = favouritedRecipes.components(separatedBy: "\n")
            }
        
        //Initialize the array
        favouriteRecipes = [Recipe]()
        
        for recipe in allRecipes {
            if let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(recipe)") {
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
                                    self.tableView.reloadData()
                                }
                            } else {
                                // Create a recipe object
                                let favRecipe = Recipe(idMeal: downloadedResults.meals[0].idMeal, strMeal: downloadedResults.meals[0].strMeal, strCategory: downloadedResults.meals[0].strCategory, strMealThumb: downloadedResults.meals[0].strMealThumb)
                                
                                self.favouriteRecipes.append(favRecipe)
                                
                            }
                        } catch let error {
                            //Print the description for the error
                            print("Problem decoding: \(error.localizedDescription)")
                            //Print the error
                            print(error)
                        }
                        
                        //Use main thread to perform updates
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                //Start the task
                fetchTask.resume()
            }
            
        }
        tableView.reloadData()
    }
    
    //MARK: - TableView Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let recipeID = favouriteRecipes[indexPath.row].idMeal {
            recipe = recipeID
        }
        
        performSegue(withIdentifier: "recipeSegue", sender: self)
    }
    
    //Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get destination view controller
        if let vc = segue.destination as? RecipeDetailViewController {
            
            // Set the recipeId
            vc.recipeId = recipe ?? "52772"
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch  editingStyle {
        case .delete:
//            var favRecipes: [String] = []
//            for recipe in allRecipes {
//                if !recipe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                    favRecipes.append(recipe)
//                }
//
//            }
            if allRecipes[indexPath.row] != "\n" {
                print(allRecipes)
                allRecipes.remove(at: indexPath.row)
                favouriteRecipes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                let file = getDocumentsDirectory().appendingPathComponent("favourites.txt")
                var favourites = ""
                for recipe in allRecipes {
                    favourites += "\(recipe)\n"
                }
                if !favourites.isEmpty {
                    try? favourites.write(to: file, atomically: true, encoding: String.Encoding.utf8)
                }
                
                // Reload the tableView
                self.tableView.reloadData()
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteRecipes.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavouritesCell", for: indexPath) as! FavouriteCell
        
        let recipe = favouriteRecipes[indexPath.row]
        
        if let recipeName = recipe.strMeal {
            cell.recipeTitle.text = recipeName
            cell.recipeTitle.layer.cornerRadius = 10
        }
        if let recipeCategory = recipe.strCategory {
            cell.recipeCategory.text = recipeCategory
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
                        cell.recipeImage.layer.cornerRadius = 10
                    }
                }
            }
        }
        
        
        return cell
    }
}


