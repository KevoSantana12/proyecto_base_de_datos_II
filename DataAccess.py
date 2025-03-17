import pyodbc

try:
    connection = pyodbc.connect(
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=KEVINSANTANA;'  
        'DATABASE=RentaAutosBaseDatosII;'
        'Trusted_Connection=yes;'
    )
    
    print("Conexión exitosa")
    
    cursor = connection.cursor()
    

    cursor.execute("SELECT * FROM dbo.Carros")
    

    for row in cursor.fetchall():
        print(row)

except Exception as e:
    print("Ocurrió un error al conectar a SQL Server: ", e)

finally:
    if 'connection' in locals():
        connection.close()
        print("Conexión cerrada")