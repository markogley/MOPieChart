# MOPieChart
An iOS PieChart written completely in swift.

###Install

Just drag the MOPieChart.swift file into your project

###Use

You need to implement the protocal and delegate inorder to use the touch parts of this code.

Set up and initialize the class variable.

  `var pieChartView = PieChartView()`

Set delegate to self in ViewController.

  `pieChartView.delegate = self`
  
Create or import your data using the Slice struct.

  ```
  let piePiece1 = Slice(value: 10, title: "Test", color: pieChartView.randomColor())
  let piePiece2 = Slice(value: 5, title: "Test2" , color: pieChartView.randomColor())
  let piePiece3 = Slice(value: 60, title: "test3", color: pieChartView.randomColor())
  
  ```
  
  set the frame for the pieChartView and add it to the subview and you are done.
  
  ```
  pieChartView.frame = view.bounds
  view.addSubview(pieChartView)
  
  ```
  
  You can turn title on by changing the showTitleLabels to true in the MOPieChart file.
  
  ```
  var showSegmentLabels = true {
        
        didSet { setNeedsDisplay() }
    }
    
  ```

  
###Example
 
 No Selection
 
 ![nosliceselected](https://cloud.githubusercontent.com/assets/1904525/21112071/ab619526-c07a-11e6-8015-48a6f6493ef3.png)
 
 Slice Selected
 
 ![sliceselected](https://cloud.githubusercontent.com/assets/1904525/21112073/ac82a008-c07a-11e6-876a-bfdb5aaa9210.png)
 
 Titles
 
 *Known bug that the title do not scale well with smaller slices.*
 
 ![titles](https://cloud.githubusercontent.com/assets/1904525/21112153/0abbb27c-c07b-11e6-8bf1-2efa3e96ffbe.png)
