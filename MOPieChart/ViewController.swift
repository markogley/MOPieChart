//
//  ViewController.swift
//  MOPieChart
//
//  Created by Mark Ogley on 2016-12-12.
//  Copyright © 2016 Mark Ogley. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PieChartViewDelegate {
    
    
    var pieChartView = PieChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //add delegate from PieChartView Class so that protocol function will fire
        pieChartView.delegate = self
        
        
        //sample data
        let piePiece1 = Slice(value: 10, title: "Slice 1", color: pieChartView.randomColor())
        let piePiece2 = Slice(value: 10, title: "Slice 2" , color: pieChartView.randomColor())
        let piePiece3 = Slice(value: 60, title: "Slice 3", color: pieChartView.randomColor())
    
        pieChartView.slices = [piePiece1, piePiece2, piePiece3]
        
        pieChartView.frame = view.bounds
        
        view.addSubview(pieChartView)
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Delegate Metod
    func slicePropertyHasChanged(newSlice: Slice?) {
        //do what ever you want with the information from the slice
        
        
        
    }

}

