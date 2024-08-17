import SwiftUI

struct PokemonsDetailView: View {
    let pokemon: ApiNetwork.PokemonsResults
    @State private var pokemonDetail: ApiNetwork.PokemonDetail?
    @State private var evolutions: [String] = []
    @State private var errorMessage: String? = nil

    var body: some View {
        ScrollView { // Usamos ScrollView para permitir desplazamiento
            VStack(alignment: .leading, spacing: 20) {
                if let detail = pokemonDetail {
                    // Mostrar la imagen del Pokémon
                    if let imageUrl = detail.sprites.front_default, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    Divider()
                    // Movimientos del Pokémon
                    Text("Movimientos")
                        .font(.title)
                        .bold()
                        .padding(.top)
                        .foregroundColor(.black)
                    // Lista para mostrar los movimientos
                    List(detail.moves.prefix(10), id: \.move.name) { move in
                            Text(move.move.name.capitalized)
                            .padding(.leading)
                    }.frame(height: 300) // Limitar la altura de la lista para que no ocupe toda la pantalla
                     .listStyle(PlainListStyle()) // Estilo más simple para la lista
                                        
                    
                    Divider() // Línea divisoria para separar secciones
                    
                    // Evoluciones
                    if !evolutions.isEmpty {
                        Text("Evoluciones")
                            .font(.title)
                            .bold()
                            .foregroundStyle(.black)
                        HStack {
                            ForEach(evolutions, id: \.self) { evolution in
                                Text(evolution.capitalized)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                    } else {
                        Text("No tiene evoluciones disponibles.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    ProgressView() // Indicador de carga mientras se obtienen los datos
                }
            }
            .padding()
            .navigationTitle(pokemon.name.capitalized)
            .task {
                await loadPokemonDetails()
            }
        }
        .background(Color.white.opacity(0.8))
    }
    
    func loadPokemonDetails() async {
        do {
            let api = ApiNetwork()
            let detail = try await api.getPokemonDetail(url: pokemon.url)
            pokemonDetail = detail
            
            // Obtener la cadena de evolución
            let evolutionUrl = try await api.getEvolutionChainUrl(forSpeciesUrl: detail.species.url)
            let evolutionChain = try await api.getEvolutionChain(url: evolutionUrl)
            
            // Procesar las evoluciones
            var evolutionList: [String] = []
            func extractEvolutions(chain: ApiNetwork.EvolutionChain.EvolutionChainLink) {
                evolutionList.append(chain.species.name)
                for evolution in chain.evolves_to {
                    extractEvolutions(chain: evolution)
                }
            }
            extractEvolutions(chain: evolutionChain.chain)
            evolutions = evolutionList
        } catch {
            errorMessage = "Error al cargar detalles del Pokémon"
        }
    }
}

#Preview {
    let mockPokemon = ApiNetwork.PokemonsResults(name: "pikachu", url: "https://pokeapi.co/api/v2/pokemon/25/")
    PokemonsDetailView(pokemon: mockPokemon)
}
