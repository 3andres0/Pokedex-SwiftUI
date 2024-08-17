import Foundation

class ApiNetwork {
    
    struct Wrapper: Codable {
        let results: [PokemonsResults]
    }
    
    struct PokemonsResults: Codable {
        let name: String
        let url: String
    }

    struct PokemonDetail: Codable {
        let sprites: Sprites
        let moves: [Move]
        let species: Species
        
        struct Sprites: Codable {
            let front_default: String?
        }
        
        struct Move: Codable {
            let move: MoveInfo
            
            struct MoveInfo: Codable {
                let name: String
            }
        }
        
        struct Species: Codable {
            let url: String
        }
    }
    
    struct EvolutionChain: Codable {
        let chain: EvolutionChainLink
        
        struct EvolutionChainLink: Codable {
            let species: PokemonSpecies
            let evolves_to: [EvolutionChainLink] // Cadena de evoluciones
            
            struct PokemonSpecies: Codable {
                let name: String
            }
        }
    }

    // Función para obtener la lista de Pokémon basada en la búsqueda
    func getPokemonsByQuery(query: String) async throws -> [PokemonsResults] {
        // Descargamos la lista completa de Pokémon
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10000&offset=0")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decodificamos los datos obtenidos en una estructura `Wrapper`
        let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
        
        // Filtramos los Pokémon cuyo nombre contiene la búsqueda
        let lowercasedQuery = query.lowercased()
        let filteredPokemons = wrapper.results.filter { $0.name.lowercased().contains(lowercasedQuery) }
        
        return filteredPokemons
    }
    
    // Función para obtener los detalles del Pokémon
    func getPokemonDetail(url: String) async throws -> PokemonDetail {
        let url = URL(string: url)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let pokemonDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)
        return pokemonDetail
    }

    // Función para obtener la cadena de evolución de un Pokémon
    func getEvolutionChain(url: String) async throws -> EvolutionChain {
        let url = URL(string: url)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let evolutionChain = try JSONDecoder().decode(EvolutionChain.self, from: data)
        return evolutionChain
    }
    
    // Función para obtener la URL de la cadena de evolución a partir de la especie del Pokémon
    func getEvolutionChainUrl(forSpeciesUrl speciesUrl: String) async throws -> String {
        let url = URL(string: speciesUrl)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let speciesData = try JSONDecoder().decode(PokemonSpeciesData.self, from: data)
        return speciesData.evolution_chain.url
    }
    
    struct PokemonSpeciesData: Codable {
        let evolution_chain: EvolutionChainUrl
        
        struct EvolutionChainUrl: Codable {
            let url: String
        }
    }
}
