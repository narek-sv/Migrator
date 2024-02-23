//
//  DirectedAcyclicGraph.swift
//
//
//  Created by Narek Sahakyan on 23.02.24.
//

final class DirectedAcyclicGraph<Vertex: Hashable> {
    private(set) var vertices = Set<Vertex>()
    private(set) var adjacencyList = [Vertex: Set<Vertex>]()

    func topologicalSort() -> [Vertex]? {
        var visited = [Vertex: Bool]()
        var stack = [Vertex]()
        
        for vertex in vertices where visited[vertex] == nil {
            dfs(parent: vertex, visited: &visited, stack: &stack)
        }
        
        var result = [Vertex]()
        var positions = [Vertex: Int]()
        var index = 0
        
        while let peek = stack.first {
            positions[peek] = index
            result.append(peek)
            index += 1
            stack.removeFirst()
        }
        
        for vertex in vertices {
            for parent in adjacencyList[vertex] ?? [] where positions[vertex]! <= positions[parent]! {
                return nil
            }
        }
        
        return result
    }
    
    func addVertex(node: Vertex, adjacents: Set<Vertex>) {
        vertices.insert(node)
        adjacencyList[node] = (adjacencyList[node] ?? [])

        for adjacent in adjacents {
            vertices.insert(adjacent)
            adjacencyList[node]?.insert(adjacent)
        }
    }
    
    // MARK: - Helpers
    
    private func dfs(parent: Vertex, visited: inout [Vertex: Bool], stack: inout [Vertex]) {
        visited[parent] = true
        
        for vertex in adjacencyList[parent] ?? [] where visited[vertex] == nil {
            dfs(parent: vertex, visited: &visited, stack: &stack)
        }

        stack.append(parent)
    }
}
