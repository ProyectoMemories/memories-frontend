// Dobles de users compartidos por los tests (sin `main`, para no
// importar un archivo de tests desde otro).
import 'package:memories/repositories/users_repository.dart';

/// Doble del repositorio: responde lo que el test indique y cuenta pedidos.
class FakeUsersRepository implements UsersRepository {
  FakeUsersRepository([Profile? profile])
    : onMyProfile = (() async => profile ?? ana);

  Future<Profile> Function() onMyProfile;
  int calls = 0;

  @override
  Future<Profile> myProfile() {
    calls++;
    return onMyProfile();
  }
}

const ana = Profile(
  firstName: 'Ana',
  paternalSurname: 'Paz',
  maternalSurname: null,
  username: 'ana.paz',
  email: 'ana@ejemplo.pe',
);

const luis = Profile(
  firstName: 'Luis',
  paternalSurname: 'Ríos',
  maternalSurname: 'Soto',
  username: 'luis.rios',
  email: 'luis@ejemplo.pe',
);
