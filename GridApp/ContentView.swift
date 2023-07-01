//
//  ContentView.swift
//  GridApp
//
//  Created by Zoe Friedman on 1/7/2023.
//

import SwiftUI

typealias Grid = [[Color]]

struct GridView: View {
    let grid: Grid
    
    let bordered: [(Int, Int)]
    
    var body: some View {
        
        VStack {
            ForEach(grid.indices, id: \.self) { rowIndex in
                let row = grid[rowIndex]
                
                HStack {
                    ForEach(row.indices, id: \.self) { colIndex in
                        if let color = grid[rowIndex][colIndex] {
                            if bordered.contains(where: { $0 == (rowIndex, colIndex) }) {
                                Rectangle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(color)
                                    .border(Color.black)
                            } else {
                                Rectangle()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(color)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    

    @State private var grid: Grid = [
        [.green, .gray, .blue, .gray, .blue],
        [.yellow, .pink, .blue, .gray, .blue],
        [.green, .pink, .purple, .gray, .blue],
        [.green, .gray, .blue, .gray, .blue],
        [.yellow, .pink, .blue, .gray, .blue]
    ]

    @State private var newGrid: Grid? = nil

    @State private var scale: String = "1"

    private let objectSubGridIndices: [(Int, Int)] = [
        (2,1), (2,2),
        (3,1), (3,2)
    ]

    var body: some View {
        VStack {
            GridView(grid: grid, bordered: objectSubGridIndices)

            Spacer()

            if let newGrid = newGrid {
                GridView(grid: newGrid, bordered: [])
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Text("Scale: ")
                    TextField("Scale", text: $scale)
                        .keyboardType(.decimalPad)
                }
                Button(action: applyScale) {
                    Text("Apply")
                }
            }
        }
        .padding()
    }

    func applyScale() {
        guard let scaleAmount = Int(scale) else { return }
        
        transformGrid(indices: objectSubGridIndices, scale: scaleAmount)
    }

    func transformGrid(indices: [(Int, Int)], scale: Int) {
        // Calculate rows and cols count
        var hashMap: [Int: [Int]] = [:]

        for index in indices {
            if hashMap[index.0] == nil {
                hashMap[index.0] = []
            }
            hashMap[index.0]?.append(index.1)
        }

        let rows = hashMap.keys.count
        let cols = hashMap[indices[0].0]?.count ?? 0

        let newRows = rows*scale
        let newCols = cols*scale

        var newGrid = Array(repeating: Array(repeating: Color.black, count: newCols), count: newRows)
        
        guard let first = indices.first else { return }
        
        let localIndicies = indices.map({ ($0.0 - first.0, $0.1 - first.1) })

        for i in localIndicies.indices {
            let localIndex = (localIndicies[i].0*scale, localIndicies[i].1*scale)
            let globalIndex = indices[i]
            let color = grid[globalIndex.0][globalIndex.1]
            
            for row in (localIndex.0)..<(localIndex.0+(scale)) {
                for col in (localIndex.1)..<(localIndex.1+(scale)) {
                    newGrid[row][col] = color
                }
            }
        }

        var gridCopy = grid

        let globalOriginRow = (first.0-(scale-1))
        let globalOriginCol = (first.1-(scale-1))

        for row in globalOriginRow..<globalOriginRow+(rows*scale) {
            for col in globalOriginCol..<globalOriginCol+(rows*scale) {
                if row >= 0, row < gridCopy.count,
                   col >= 0, col < gridCopy[0].count {
                    gridCopy[row][col] = newGrid[row-globalOriginRow][col-globalOriginCol]
                }
            }
        }
        
        
        self.newGrid = gridCopy
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
