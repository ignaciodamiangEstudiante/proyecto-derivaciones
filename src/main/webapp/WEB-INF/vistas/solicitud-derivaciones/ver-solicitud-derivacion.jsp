<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<html>
<head>
    <%@ include file="../../../parts/meta.jsp" %>
    <title>Ver Derivacion</title>
</head>
<body>
<!-- se agrega la columna menu -->
<%@ include file="../../../parts/menu.jsp" %>
<div class="col-10" id="main">
    <!--  fin menu -->
    <div class="row p-3  d-flex">
        <div class="d-flex flex-grow-1">
            <form class="form-group d-flex" method="get" action="/proyecto_derivaciones_war_exploded/ver-derivacion/">
                <input class="form-control" name="id" type="text" placeholder="Ingrese id de derivacion">
                <input type="submit" class="btn btn-primary w-25 ml-4" value="Buscar">
            </form>
        </div>
        <c:if test="${rol =='Derivador' || rol =='Solicitador'}">
            <div class="px-3">
                <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#CancelarDerivacion${derivacion.getId() }">Cancelar derivacion</button>
            </div>
        </c:if>
        <c:if test="${rol =='Derivador' && derivacion.getEstadoDerivacion().toString().equals('ENBUSQUEDA')}">
            <div class="px-3">
                <a href="../nueva-solicitud-derivacion/${derivacion.id} "class="btn btn-primary">Generar Solicitud</a>
            </div>
        </c:if>
        <c:if test="${solicitud.aceptado == true && rol =='Derivador'}">
            <td>
                <div class="px-3">
                    <a href="../crearTraslado/${solicitud.id}"class="btn btn-primary"  role="button">Generar Traslado</a>
                </div>
            </td>
        </c:if>

    </div>
    <div class="row">
        <div class="col">
            <div class="row">
                <div class="col m-2">
                    <div class="row m-1"> <strong>Id Solicitud: </strong><p> ${solicitud.getCodigo()}</p></div>
                    <div class="row m-1"> <strong>Sector: </strong><p> ${solicitud.getDerivacion().getParaQueSector()}</p></div>
                    <div class="row m-1"> <strong>requisitos: </strong>
                        <c:choose>
                            <c:when test="${solicitud.getDerivacion().getRequerimientosMedicos().getTomografo()}">
                                - TOMOGRAFO <br>
                            </c:when>
                            <c:when test="${solicitud.getDerivacion().getRequerimientosMedicos().getTraumatologoDeguardia()}">
                                - TRAUMATOLOGO DE GUARDIA <br>
                            </c:when>
                            <c:when test="${solicitud.getDerivacion().getRequerimientosMedicos().getCirujanoDeGuardia()}">
                                - CIRUJANO DE GUARDIA <br>
                            </c:when>
                            <c:when test="${solicitud.getDerivacion().getRequerimientosMedicos().getCardiologoSeGuardia()}">
                                - CARDIOLOGO DE GUARDIA <br>
                            </c:when>
                            <c:otherwise>
                                - NINGUNO <br>
                            </c:otherwise>
                        </c:choose>

                    </div>
                </div>
                <div class="col m-2">
                    <div class="row m-1"> <strong>Paciente: </strong>
                        <a data-toggle="modal" data-target="#paciente${solicitud.getDerivacion().getPaciente().getId()}">${solicitud.getDerivacion().getPaciente().getNombreCompleto()}</a>
                    </div>
                    <!-- Modal -->
                    <div class="modal fade" id="paciente${solicitud.getDerivacion().getPaciente().getId()}">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <!-- Modal Header -->
                                <div class="modal-header">
                                    <img src="${pageContext.servletContext.contextPath}/img/pacientes/${solicitud.getDerivacion().getPaciente().getFoto()}" class="rounded-circle img-fluid img-thumbnail" alt="${derivacion.getPaciente().getFoto()}" width="80">
                                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                                </div>
                                <!-- Modal body -->
                                <div class="modal-body">
                                    <h4>Nombre de paciente: </h4>
                                    <span>${solicitud.getDerivacion().getPaciente().getNombreCompleto()}</span>
                                    <h4>DNI: </h4>
                                    <span>${solicitud.getDerivacion().getPaciente().getDocumento()}</span>
                                    <h4>Fecha nacimiento paciente: </h4>
                                    <span>${solicitud.getDerivacion().getPaciente().getFechaNacimiento()}</span>
                                </div>
                                <!-- Modal footer -->
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row m-1"> <strong>Urgente: </strong>
                        <c:choose>
                            <c:when test="${solicitud.getDerivacion().getUrgente()}">
                                <p class="text-center px-2" style="background: darkred;color: white;">URGENTE</p>
                            </c:when>
                            <c:otherwise>
                                <p class="text-center"> NO </p>
                            </c:otherwise>
                        </c:choose></div>
                </div>
                <div class="col m-2">
                    <div class="row m-1"> <strong>Estado: </strong><p>${solicitud.getDerivacion().getEstadoDerivacion()}</p></div>
                    <div class="row m-1"> <strong>Fecha generacion: </strong><p>${solicitud.getDerivacion().getFechaDerivacion()}</p></div>
                    <div class="row m-1"> <strong>Cobertura: </strong><p>${solicitud.getDerivacion().getCobertura().getNombre()}</p></div>
                </div>
            </div>
        </div>
    </div>
    <!--  agregar div con rows -->
    <div class="row">
        <div class="col m-2">
            <strong>Descripcion: </strong> <p>${solicitud.getDescripcion()}</p>
        </div>
    </div>
    <!-- <div class="row bg-warning"> -->
    <p class="d-flex justify-content-around">
        <button class="btn btn-primary" onclick="mostrarOcultar('registros')">Registro</button>
        <button class="btn btn-primary" onclick="mostrarOcultar('adjuntos')">Adjuntos</button>

    </p>
    <div class="">
        <div class="row" id="registros"> <table class="table table-striped">
            <thead>
            <tr>
                <th scope="col">Fecha</th>
                <th scope="col">Asunto</th>
                <th scope="col">Usuario</th>
                <th scope="col">Evento</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${comentarios}" var="comentario">
                <tr>
                    <td>${comentario.getFechaCreacion()}</td>
                    <td>${comentario.getAsunto()}</td>
                    <td>${comentario.getAutor().getEmail()}</td>
                    <td>${comentario.getMensaje()}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table></div>
        <div class="row" id="adjuntos"> <table class="table table-striped">
            <thead>
            <tr>
                <th scope="col">#</th>
                <th scope="col">Adjunto</th>
                <th scope="col">Last</th>
                <th scope="col">Handle</th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <th scope="row">1</th>
                <td>Mark</td>
                <td>Otto</td>
                <td>@mdo</td>
            </tr>
            <tr>
                <th scope="row">2</th>
                <td>Jacob</td>
                <td>Thornton</td>
                <td>@fat</td>
            </tr>
            <tr>
                <th scope="row">3</th>
                <td colspan="2">Larry the Bird</td>
                <td>@twitter</td>
            </tr>
            </tbody>
        </table></div>
        <!-- </div> -->
    </div>
    <div class="row">
        <div class="col m-2">
            <strong>Diagnostico: </strong> <p>${derivacion.getDiagnostico()}</p>
        </div>
    </div>
    <div class="row">
        <div class="col m-2">
            <strong>Diagnostico: </strong> <p>${derivacion.getDiagnostico()}</p>
        </div>
    </div>
</div>
<div class="modal fade" id="CancelarDerivacion${derivacion.getId()}">
    <div class="modal-dialog">
        <div class="modal-content">
            <!-- Modal Header -->
            <div class="modal-header">
                <h5>Cancelar derivación</h5>
            </div>
            <!-- Modal body -->
            <div class="modal-body">
                <form action="../cancelar-derivacion/${derivacion.getId() }" method="post">
                    <label>Motivo:</label>
                    <textarea name="mensaje" rows="5" cols="50"></textarea>
                    <button type="submit" class="btn btn-danger">Confirmar anulacion</button>
                </form>
            </div>
            <!-- Modal footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-danger" data-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>
<!--  fin de divs con rows -->
<!--  footer -->
</div>

<%@ include file="../../../parts/footer.jsp" %>
<script>
    function mostrarOcultar(id){
        switch(id){
            case 'solicitudes':
                if(document.getElementById('solicitudes').style.display == 'initial'){
                    return document.getElementById('solicitudes').style.display ='none';
                }
                document.getElementById('solicitudes').style.display='initial';
                document.getElementById('registros').style.display='none';
                document.getElementById('adjuntos').style.display='none';
                break;
            case 'registros':
                if(document.getElementById('registros').style.display == 'initial'){
                    return document.getElementById('registros').style.display ='none';
                }
                document.getElementById('registros').style.display='initial';
                document.getElementById('solicitudes').style.display='none';
                document.getElementById('adjuntos').style.display='none';
                break;
            case 'adjuntos':
                if(document.getElementById('adjuntos').style.display == 'initial'){
                    return document.getElementById('adjuntos').style.display ='none';
                }
                document.getElementById('adjuntos').style.display='initial';
                document.getElementById('solicitudes').style.display='none';
                document.getElementById('registros').style.display='none';
                break;
            default:
                document.getElementById('solicitudes').style.display='none';
                document.getElementById('registros').style.display='none';
                document.getElementById('adjuntos').style.display='none';
                break;
        }

    }
</script>
</body>
</html>