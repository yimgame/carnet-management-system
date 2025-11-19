"""
Backend API Example para Sistema de Gestión de Carnets - ARCOR
Este es un ejemplo usando Python + Flask + SQLAlchemy

Para ejecutar:
1. Instalar dependencias: pip install flask flask-cors sqlalchemy pandas openpyxl
2. Ejecutar: python backend_api.py
3. La API estará disponible en http://localhost:5000
"""

from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from sqlalchemy import create_engine, Column, Integer, String, Date, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime, timedelta
import pandas as pd
import io

app = Flask(__name__)
CORS(app)  # Permitir CORS para conexión con frontend

# Configuración de base de datos (SQLite para desarrollo, cambiar a MySQL/PostgreSQL en producción)
DATABASE_URL = "sqlite:///carnets.db"
# Para MySQL: "mysql+pymysql://usuario:password@localhost/carnets_arcor"
# Para PostgreSQL: "postgresql://usuario:password@localhost/carnets_arcor"

engine = create_engine(DATABASE_URL)
Base = declarative_base()
Session = sessionmaker(bind=engine)

# Modelo de datos
class Carnet(Base):
    __tablename__ = 'carnets'
    
    id = Column(Integer, primary_key=True)
    apellido = Column(String(100), nullable=False)
    nombre = Column(String(100), nullable=False)
    dni = Column(String(20), unique=True, nullable=False)
    legajo = Column(String(50), nullable=False)
    fecha_calificacion = Column(Date, nullable=False)
    fecha_vencimiento = Column(Date, nullable=False)
    apto_medico = Column(String(20), default='Apto')
    empresa = Column(String(100), default='ARCOR SAIC')
    tipo_autorizacion = Column(String(200), default='Autoelevador 2240 Kg')
    resolucion = Column(String(50), default='960/2015')
    fecha_creacion = Column(DateTime, default=datetime.now)
    fecha_actualizacion = Column(DateTime, default=datetime.now, onupdate=datetime.now)
    activo = Column(Boolean, default=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'apellido': self.apellido,
            'nombre': self.nombre,
            'dni': self.dni,
            'legajo': self.legajo,
            'fecha_calificacion': self.fecha_calificacion.strftime('%Y-%m-%d') if self.fecha_calificacion else None,
            'fecha_vencimiento': self.fecha_vencimiento.strftime('%Y-%m-%d') if self.fecha_vencimiento else None,
            'apto_medico': self.apto_medico,
            'empresa': self.empresa,
            'tipo_autorizacion': self.tipo_autorizacion,
            'resolucion': self.resolucion,
            'estado': self.get_estado()
        }
    
    def get_estado(self):
        if not self.fecha_vencimiento:
            return 'unknown'
        
        hoy = datetime.now().date()
        dias_diferencia = (self.fecha_vencimiento - hoy).days
        
        if dias_diferencia < 0:
            return 'expired'
        elif dias_diferencia <= 30:
            return 'warning'
        else:
            return 'active'

# Crear tablas
Base.metadata.create_all(engine)

# Rutas de la API

@app.route('/api/carnets', methods=['GET'])
def get_carnets():
    """Obtener todos los carnets activos"""
    session = Session()
    try:
        carnets = session.query(Carnet).filter_by(activo=True).all()
        return jsonify([carnet.to_dict() for carnet in carnets])
    finally:
        session.close()

@app.route('/api/carnets/<int:carnet_id>', methods=['GET'])
def get_carnet(carnet_id):
    """Obtener un carnet específico"""
    session = Session()
    try:
        carnet = session.query(Carnet).filter_by(id=carnet_id, activo=True).first()
        if carnet:
            return jsonify(carnet.to_dict())
        return jsonify({'error': 'Carnet no encontrado'}), 404
    finally:
        session.close()

@app.route('/api/carnets', methods=['POST'])
def create_carnet():
    """Crear un nuevo carnet"""
    session = Session()
    try:
        data = request.get_json()
        
        # Validar DNI único
        if session.query(Carnet).filter_by(dni=data['dni'], activo=True).first():
            return jsonify({'error': 'Ya existe un carnet con ese DNI'}), 400
        
        carnet = Carnet(
            apellido=data['apellido'],
            nombre=data['nombre'],
            dni=data['dni'],
            legajo=data['legajo'],
            fecha_calificacion=datetime.strptime(data['fecha_calificacion'], '%Y-%m-%d').date(),
            fecha_vencimiento=datetime.strptime(data['fecha_vencimiento'], '%Y-%m-%d').date(),
            apto_medico=data.get('apto_medico', 'Apto')
        )
        
        session.add(carnet)
        session.commit()
        
        return jsonify(carnet.to_dict()), 201
    except Exception as e:
        session.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        session.close()

@app.route('/api/carnets/<int:carnet_id>', methods=['PUT'])
def update_carnet(carnet_id):
    """Actualizar un carnet existente"""
    session = Session()
    try:
        carnet = session.query(Carnet).filter_by(id=carnet_id, activo=True).first()
        
        if not carnet:
            return jsonify({'error': 'Carnet no encontrado'}), 404
        
        data = request.get_json()
        
        carnet.apellido = data.get('apellido', carnet.apellido)
        carnet.nombre = data.get('nombre', carnet.nombre)
        carnet.dni = data.get('dni', carnet.dni)
        carnet.legajo = data.get('legajo', carnet.legajo)
        
        if 'fecha_calificacion' in data:
            carnet.fecha_calificacion = datetime.strptime(data['fecha_calificacion'], '%Y-%m-%d').date()
        if 'fecha_vencimiento' in data:
            carnet.fecha_vencimiento = datetime.strptime(data['fecha_vencimiento'], '%Y-%m-%d').date()
        
        carnet.apto_medico = data.get('apto_medico', carnet.apto_medico)
        
        session.commit()
        
        return jsonify(carnet.to_dict())
    except Exception as e:
        session.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        session.close()

@app.route('/api/carnets/<int:carnet_id>', methods=['DELETE'])
def delete_carnet(carnet_id):
    """Eliminar (desactivar) un carnet"""
    session = Session()
    try:
        carnet = session.query(Carnet).filter_by(id=carnet_id, activo=True).first()
        
        if not carnet:
            return jsonify({'error': 'Carnet no encontrado'}), 404
        
        carnet.activo = False
        session.commit()
        
        return jsonify({'message': 'Carnet eliminado correctamente'})
    except Exception as e:
        session.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        session.close()

@app.route('/api/carnets/alertas', methods=['GET'])
def get_alertas():
    """Obtener carnets con alertas de vencimiento"""
    session = Session()
    try:
        hoy = datetime.now().date()
        limite = hoy + timedelta(days=30)
        
        carnets = session.query(Carnet).filter(
            Carnet.activo == True,
            Carnet.fecha_vencimiento <= limite
        ).all()
        
        return jsonify([carnet.to_dict() for carnet in carnets])
    finally:
        session.close()

@app.route('/api/estadisticas', methods=['GET'])
def get_estadisticas():
    """Obtener estadísticas generales"""
    session = Session()
    try:
        carnets = session.query(Carnet).filter_by(activo=True).all()
        
        total = len(carnets)
        vigentes = sum(1 for c in carnets if c.get_estado() == 'active')
        por_vencer = sum(1 for c in carnets if c.get_estado() == 'warning')
        vencidos = sum(1 for c in carnets if c.get_estado() == 'expired')
        
        return jsonify({
            'total_carnets': total,
            'vigentes': vigentes,
            'por_vencer': por_vencer,
            'vencidos': vencidos
        })
    finally:
        session.close()

@app.route('/api/carnets/buscar', methods=['GET'])
def buscar_carnets():
    """Buscar carnets por varios criterios"""
    session = Session()
    try:
        busqueda = request.args.get('q', '').lower()
        estado = request.args.get('estado', None)
        
        query = session.query(Carnet).filter_by(activo=True)
        
        if busqueda:
            query = query.filter(
                (Carnet.apellido.ilike(f'%{busqueda}%')) |
                (Carnet.nombre.ilike(f'%{busqueda}%')) |
                (Carnet.dni.ilike(f'%{busqueda}%')) |
                (Carnet.legajo.ilike(f'%{busqueda}%'))
            )
        
        carnets = query.all()
        
        # Filtrar por estado si se especifica
        if estado:
            carnets = [c for c in carnets if c.get_estado() == estado]
        
        return jsonify([carnet.to_dict() for carnet in carnets])
    finally:
        session.close()

@app.route('/api/carnets/import-excel', methods=['POST'])
def import_excel():
    """Importar carnets desde archivo Excel"""
    session = Session()
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No se proporcionó archivo'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'Archivo vacío'}), 400
        
        # Leer Excel
        df = pd.read_excel(file)
        
        importados = 0
        errores = []
        
        for index, row in df.iterrows():
            try:
                # Verificar si ya existe
                if session.query(Carnet).filter_by(dni=str(row['DNI']), activo=True).first():
                    errores.append(f"Fila {index + 2}: DNI {row['DNI']} ya existe")
                    continue
                
                carnet = Carnet(
                    apellido=str(row['Apellido']),
                    nombre=str(row['Nombre']),
                    dni=str(row['DNI']),
                    legajo=str(row['Legajo']),
                    fecha_calificacion=pd.to_datetime(row['Fecha_Calificacion']).date(),
                    fecha_vencimiento=pd.to_datetime(row['Fecha_Vencimiento']).date(),
                    apto_medico=str(row.get('Apto_Medico', 'Apto'))
                )
                
                session.add(carnet)
                importados += 1
            except Exception as e:
                errores.append(f"Fila {index + 2}: {str(e)}")
        
        session.commit()
        
        return jsonify({
            'message': f'Importación completada',
            'importados': importados,
            'errores': errores
        })
    except Exception as e:
        session.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        session.close()

@app.route('/api/carnets/export-excel', methods=['GET'])
def export_excel():
    """Exportar carnets a archivo Excel"""
    session = Session()
    try:
        carnets = session.query(Carnet).filter_by(activo=True).all()
        
        data = [{
            'Apellido': c.apellido,
            'Nombre': c.nombre,
            'DNI': c.dni,
            'Legajo': c.legajo,
            'Fecha_Calificacion': c.fecha_calificacion.strftime('%d/%m/%Y'),
            'Fecha_Vencimiento': c.fecha_vencimiento.strftime('%d/%m/%Y'),
            'Apto_Medico': c.apto_medico,
            'Estado': c.get_estado().upper()
        } for c in carnets]
        
        df = pd.DataFrame(data)
        
        # Crear archivo Excel en memoria
        output = io.BytesIO()
        with pd.ExcelWriter(output, engine='openpyxl') as writer:
            df.to_excel(writer, index=False, sheet_name='Carnets')
        output.seek(0)
        
        return send_file(
            output,
            mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            as_attachment=True,
            download_name=f'carnets_arcor_{datetime.now().strftime("%Y%m%d")}.xlsx'
        )
    finally:
        session.close()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'ok', 'timestamp': datetime.now().isoformat()})

if __name__ == '__main__':
    print("🚀 Backend API iniciada en http://localhost:5000")
    print("📊 Endpoints disponibles:")
    print("   GET    /api/carnets              - Listar todos los carnets")
    print("   GET    /api/carnets/<id>         - Obtener carnet específico")
    print("   POST   /api/carnets              - Crear nuevo carnet")
    print("   PUT    /api/carnets/<id>         - Actualizar carnet")
    print("   DELETE /api/carnets/<id>         - Eliminar carnet")
    print("   GET    /api/carnets/alertas      - Obtener alertas")
    print("   GET    /api/estadisticas         - Obtener estadísticas")
    print("   GET    /api/carnets/buscar?q=... - Buscar carnets")
    print("   POST   /api/carnets/import-excel - Importar desde Excel")
    print("   GET    /api/carnets/export-excel - Exportar a Excel")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
