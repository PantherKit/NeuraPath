// Inicialización de MongoDB para NeuraPath
db = db.getSiblingDB('neurapath');

// Crear usuario para la aplicación
db.createUser({
  user: 'neurapath_user',
  pwd: 'neurapath_password',
  roles: [
    {
      role: 'readWrite',
      db: 'neurapath'
    }
  ]
});

print('✅ Usuario de NeuraPath creado en MongoDB');