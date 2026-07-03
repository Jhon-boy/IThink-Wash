-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.torgsucursal (
  idsucursal integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying NOT NULL,
  direccion character varying NOT NULL,
  estado boolean,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  latitud numeric,
  longitud numeric,
  contacto character varying,
  CONSTRAINT torgsucursal_pkey PRIMARY KEY (idsucursal)
);
CREATE TABLE public.tperpersona (
  idpersona integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  identificacion character varying UNIQUE,
  nombres character varying NOT NULL,
  apellidos character varying NOT NULL,
  fnacimiento timestamp without time zone,
  genero character varying,
  correo character varying,
  telefono character varying,
  direccion character varying,
  tipoidentificacion character varying,
  estado character varying,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tperpersona_pkey PRIMARY KEY (idpersona)
);
CREATE TABLE public.tsegrol (
  idrol integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying NOT NULL,
  codigo character varying UNIQUE,
  observacion character varying,
  estado character varying NOT NULL,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tsegrol_pkey PRIMARY KEY (idrol)
);
CREATE TABLE public.tsegcanal (
  idcanal integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying NOT NULL UNIQUE,
  descripcion character varying,
  estado character varying NOT NULL,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tsegcanal_pkey PRIMARY KEY (idcanal)
);
CREATE TABLE public.tsegusuario (
  idusuario integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idsucursal integer NOT NULL,
  idpersona integer NOT NULL,
  usuario character varying NOT NULL UNIQUE,
  password character varying NOT NULL,
  temporal boolean DEFAULT false,
  estado character varying NOT NULL,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tsegusuario_pkey PRIMARY KEY (idusuario),
  CONSTRAINT tsegusuario_idsucursal_fkey FOREIGN KEY (idsucursal) REFERENCES public.torgsucursal(idsucursal),
  CONSTRAINT tsegusuario_idpersona_fkey FOREIGN KEY (idpersona) REFERENCES public.tperpersona(idpersona)
);
CREATE TABLE public.tsegrolusuario (
  idrolusuario integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idrol integer NOT NULL,
  idusuario integer NOT NULL,
  estado character varying NOT NULL,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tsegrolusuario_pkey PRIMARY KEY (idrolusuario),
  CONSTRAINT tsegrolusuario_idrol_fkey FOREIGN KEY (idrol) REFERENCES public.tsegrol(idrol),
  CONSTRAINT tsegrolusuario_idusuario_fkey FOREIGN KEY (idusuario) REFERENCES public.tsegusuario(idusuario)
);
CREATE TABLE public.tsegusuariocanal (
  idusuariocanal integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idusuario integer NOT NULL,
  idcanal integer NOT NULL,
  estado character varying NOT NULL,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tsegusuariocanal_pkey PRIMARY KEY (idusuariocanal),
  CONSTRAINT tsegusuariocanal_idusuario_fkey FOREIGN KEY (idusuario) REFERENCES public.tsegusuario(idusuario),
  CONSTRAINT tsegusuariocanal_idcanal_fkey FOREIGN KEY (idcanal) REFERENCES public.tsegcanal(idcanal)
);
CREATE TABLE public.tsegdispositivo (
  iddispositivo integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idusuario integer NOT NULL,
  imei character varying UNIQUE,
  marca character varying,
  modelo character varying,
  sistemaoperativo character varying,
  versionso character varying,
  nombredispositivo character varying,
  ultimoacceso timestamp without time zone,
  activo boolean DEFAULT true,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tsegdispositivo_pkey PRIMARY KEY (iddispositivo),
  CONSTRAINT tsegdispositivo_idusuario_fkey FOREIGN KEY (idusuario) REFERENCES public.tsegusuario(idusuario)
);
CREATE TABLE public.tsegsesion (
  idsesion uuid NOT NULL DEFAULT gen_random_uuid(),
  idusuario integer NOT NULL,
  idcanal integer NOT NULL,
  iddispositivo integer,
  token uuid NOT NULL UNIQUE,
  fechainicio timestamp with time zone DEFAULT now(),
  fechaexpiracion timestamp with time zone NOT NULL,
  activo boolean DEFAULT true,
  CONSTRAINT tsegsesion_pkey PRIMARY KEY (idsesion),
  CONSTRAINT tsegsesion_idusuario_fkey FOREIGN KEY (idusuario) REFERENCES public.tsegusuario(idusuario),
  CONSTRAINT tsegsesion_idcanal_fkey FOREIGN KEY (idcanal) REFERENCES public.tsegcanal(idcanal),
  CONSTRAINT tsegsesion_iddispositivo_fkey FOREIGN KEY (iddispositivo) REFERENCES public.tsegdispositivo(iddispositivo)
);
CREATE TABLE public.tserconcepto (
  idconcepto integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying NOT NULL,
  descripcion character varying,
  tipocobro character varying NOT NULL,
  unidadmedida character varying,
  preciobase numeric NOT NULL,
  estado character varying NOT NULL,
  imagen character varying,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tserconcepto_pkey PRIMARY KEY (idconcepto)
);
CREATE TABLE public.tserservicioadicional (
  idservicioadicional integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  nombre character varying NOT NULL,
  descripcion character varying,
  preciobase numeric NOT NULL,
  estado character varying NOT NULL,
  imagen character varying,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tserservicioadicional_pkey PRIMARY KEY (idservicioadicional)
);
CREATE TABLE public.tordorden (
  idorden integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idsucursal integer NOT NULL,
  idpersona integer NOT NULL,
  idempleado integer NOT NULL,
  numeroorden character varying UNIQUE,
  fecharecepcion timestamp without time zone NOT NULL,
  fechaentregaestimada timestamp without time zone,
  fechaentregareal timestamp without time zone,
  subtotal numeric,
  total numeric,
  totalabonado numeric DEFAULT 0,
  saldopendiente numeric,
  estado character varying NOT NULL,
  comentario character varying,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tordorden_pkey PRIMARY KEY (idorden),
  CONSTRAINT tordorden_idsucursal_fkey FOREIGN KEY (idsucursal) REFERENCES public.torgsucursal(idsucursal),
  CONSTRAINT tordorden_idpersona_fkey FOREIGN KEY (idpersona) REFERENCES public.tperpersona(idpersona),
  CONSTRAINT tordorden_idempleado_fkey FOREIGN KEY (idempleado) REFERENCES public.tsegusuario(idusuario)
);
CREATE TABLE public.tordordendetalle (
  idordendetalle integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idorden integer NOT NULL,
  idconcepto integer NOT NULL,
  descripcionprenda character varying,
  cantidad numeric,
  preciounitario numeric,
  subtotal numeric,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tordordendetalle_pkey PRIMARY KEY (idordendetalle),
  CONSTRAINT tordordendetalle_idorden_fkey FOREIGN KEY (idorden) REFERENCES public.tordorden(idorden),
  CONSTRAINT tordordendetalle_idconcepto_fkey FOREIGN KEY (idconcepto) REFERENCES public.tserconcepto(idconcepto)
);
CREATE TABLE public.tordordendetalleadicional (
  idordendetalleadicional integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idordendetalle integer,
  idservicioadicional integer,
  precioaplicado numeric,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tordordendetalleadicional_pkey PRIMARY KEY (idordendetalleadicional),
  CONSTRAINT tordordendetalleadicional_idordendetalle_fkey FOREIGN KEY (idordendetalle) REFERENCES public.tordordendetalle(idordendetalle),
  CONSTRAINT tordordendetalleadicional_idservicioadicional_fkey FOREIGN KEY (idservicioadicional) REFERENCES public.tserservicioadicional(idservicioadicional)
);
CREATE TABLE public.tordpago (
  idpago integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idorden integer,
  tipopago character varying,
  metodopago character varying,
  monto numeric,
  fechapago timestamp without time zone,
  referencia character varying,
  estado character varying,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tordpago_pkey PRIMARY KEY (idpago),
  CONSTRAINT tordpago_idorden_fkey FOREIGN KEY (idorden) REFERENCES public.tordorden(idorden)
);

CREATE TABLE public.tfinmovimiento (
  idmovimiento integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  idsucursal integer NOT NULL,
  tipo character varying,
  categoria character varying,
  descripcion character varying,
  monto numeric,
  fecha timestamp without time zone,
  referencia character varying,
  estado character varying,
  comentario character varying,
  fcreacion timestamp without time zone,
  fmodificacion timestamp without time zone,
  usuariocreacion character varying,
  usuariomodificacion character varying,
  CONSTRAINT tfinmovimiento_pkey PRIMARY KEY (idmovimiento),
  CONSTRAINT tfinmovimiento_idsucursal_fkey FOREIGN KEY (idsucursal) REFERENCES public.torgsucursal(idsucursal)
);