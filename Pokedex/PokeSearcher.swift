import SwiftUI

struct PokeSearcher: View {
    @State var pokemonName: String = ""
    @State private var pokemons: [ApiNetwork.PokemonsResults] = [] // Variable para almacenar los resultados de la búsqueda
    @State private var errorMessage: String? = nil // Para manejar errores
    
    var body: some View {
        NavigationStack {
            VStack {
                // Campo de búsqueda
                Text("Buscar Pokémon")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                TextField("Buscar Pokémon...", text: $pokemonName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: pokemonName) { newValue in
                        Task {
                            if !newValue.isEmpty {
                                do {
                                    let api = ApiNetwork()
                                    let results = try await api.getPokemonsByQuery(query: newValue)
                                    pokemons = results
                                    errorMessage = nil
                                } catch {
                                    errorMessage = "Error al buscar Pokémon."
                                }
                            } else {
                                pokemons = []
                            }
                        }
                    }

                // Mostrar mensaje de error si ocurre
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Mostrar lista de resultados
                List(pokemons, id: \.name) { pokemon in
                    NavigationLink(destination: PokemonsDetailView(pokemon: pokemon)) {
                        Text(pokemon.name.capitalized)
                    }
                }
            }
            //.navigationTitle("Buscar Pokémon").foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.9))
        }
    }
}


#Preview {
    PokeSearcher()
}
