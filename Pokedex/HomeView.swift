import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack { // Añadir NavigationStack para habilitar la navegación
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                Image("HomePoke")
                    .resizable()
                    .scaledToFit()
                NavigationLink(destination: PokeSearcher()) {
                    Text("Iniciemos...")
                        .bold()
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red) // Opcional: añadir un fondo al botón
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        }
    }
}

#Preview {
    HomeView()
}
