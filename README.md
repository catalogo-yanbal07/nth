# Catálogo Yanbal

Catálogo público de productos servido por GitHub Pages. Los visitantes pueden
consultar los productos y precios; solo la cuenta administradora puede crear,
editar o eliminar productos.

## Servicios

- GitHub Pages sirve `index.html`.
- Supabase Auth protege el acceso de administración.
- Supabase Database conserva el catálogo y aplica las políticas RLS definidas
  en [`supabase-setup.sql`](./supabase-setup.sql).

La clave `sb_publishable` del cliente está diseñada para usarse en el navegador.
No añadas claves secretas de Supabase a este repositorio. Las políticas RLS son
las que protegen las operaciones de escritura.

## Primera configuración de la administradora

1. Abre el catálogo público y selecciona **Administrar**.
2. Crea una cuenta con tu correo y una contraseña segura.
3. Confirma el correo si Supabase lo solicita e inicia sesión.
4. Introduce el código de configuración de un solo uso que se entregó aparte.
5. Después de activarlo, guarda la contraseña en un gestor seguro. El código de
   configuración no se debe publicar ni compartir.

La base de datos guarda las fotos como imágenes comprimidas dentro del producto.
