package ar.edu.unlam.tallerweb1.controladores;

import ar.edu.unlam.tallerweb1.modelo.*;
import ar.edu.unlam.tallerweb1.servicios.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpServletRequest;
import java.util.HashSet;
import java.util.List;

@Controller
public class ControladorSolicitudDerivaciones {
    private ServicioSolicitudDerivacion servicioSolicitudDerivacion;
    private ServicioDerivacion servicioDerivacion;
    private ServicioCentroMedico servicioCentroMedico;
    private ServicioNotificacion servicioNotificacion;
    private ServicioNotificacionUsuario servicioNotificacionUsuario;
    private ServicioCentroMedicoDistancia servicioCentroMedicoDistancia;
    private ServicioComentario servicioComentario;
    private ServicioAdjunto servicioAdjunto;

    @Autowired
    public ControladorSolicitudDerivaciones
            (ServicioSolicitudDerivacion servicio, ServicioDerivacion servicioDerivacion, ServicioCentroMedico servicioCentroMedico,
             ServicioNotificacion servicioNotificacion, ServicioNotificacionUsuario servicioNotificacionUsuario, ServicioComentario servicioComentario,
             ServicioAdjunto servicioAdjunto) {
        this.servicioSolicitudDerivacion = servicio;
        this.servicioDerivacion = servicioDerivacion;
        this.servicioCentroMedico = servicioCentroMedico;
        this.servicioNotificacion = servicioNotificacion;
        this.servicioNotificacionUsuario = servicioNotificacionUsuario;
        this.servicioComentario = servicioComentario;
        this.servicioCentroMedicoDistancia = new ServicioCentroMedicoDistanciaImpl();
        this.servicioAdjunto = servicioAdjunto;
    }

    @RequestMapping("/solicitudes-derivaciones")
    public ModelAndView mostrarSolicitudesDerivaciones( HttpServletRequest request) throws Exception {
        ModelMap modelo = new ModelMap();
        Long id = (Long) request.getSession().getAttribute("ID_CENTROMEDICO");
        CentroMedico centro = servicioCentroMedico.obtenerCentroMedicoPorId(id);
        List<SolicitudDerivacion> lista = servicioSolicitudDerivacion.obtenerSolicitudesDeDerivacionPorCentroMedico(centro);
        modelo.put("listaSolicitudesDerivaciones", lista);
        modelo.put("rol",request.getSession().getAttribute("ROL"));
        modelo.put("cantNotificacion",servicioNotificacionUsuario.obtenerNotificacionesNoLeidas(request));
        return new ModelAndView("/solicitud-derivaciones/solicitud-derivaciones", modelo);
    }

    @RequestMapping(path = "/nueva-solicitud-derivacion/{idDerivacion}",method = RequestMethod.GET)
    public ModelAndView nuevaSolicitudDerivacion(@PathVariable Long idDerivacion, HttpServletRequest request) throws Exception {
        ModelMap model = new ModelMap();
        SolicitudDerivacion solicitudDerivacion = new SolicitudDerivacion();
        Derivacion derivacion = servicioDerivacion.verDerivacion(idDerivacion);
        HashSet<CentroMedico> centroMedicos = servicioCentroMedico.centrosMedicosQuePoseenRequerimientosMedicos(servicioCentroMedico.obtenerCentrosMedicosPorPaciente(derivacion.getPaciente()), derivacion.getRequerimientosMedicos());
        List<CentroMedicoDistancia> centroMedicoDistancias = servicioCentroMedicoDistancia.obtenerDistanciaCentroMedicoPaciente(centroMedicos,derivacion);
        model.put("derivaciones", derivacion);
        model.put("centrosMedicos", centroMedicoDistancias);
        model.put("solicitudDerivacion", solicitudDerivacion);
        model.put("cantNotificacion",servicioNotificacionUsuario.obtenerNotificacionesNoLeidas(request));
        return new ModelAndView("/solicitud-derivaciones/agregar-solicitud-derivacion", model);
    }
    @RequestMapping(path = "/ver-solicitud-derivacion/{idSolicitud}",method = RequestMethod.GET)
    public ModelAndView verDerivacion(@PathVariable Long idSolicitud, HttpServletRequest request) throws Exception {
        ModelMap model = new ModelMap();
        SolicitudDerivacion solicitudDerivacion = servicioSolicitudDerivacion.obtenerSolicitudDerivacionPorId(idSolicitud);
        List<Comentario> comentarios = servicioComentario.obtenerComentariosPorSolicitudDerivacion(solicitudDerivacion);
        List<Adjunto> adjuntos = servicioAdjunto.listarAdjuntosPorSolicitudDerivacion(solicitudDerivacion);
        model.put("rol",request.getSession().getAttribute("ROL"));
        model.put("solicitud",solicitudDerivacion);
        model.put("adjuntos", adjuntos);
        model.put("comentarios", comentarios);
        model.put("cantNotificacion",servicioNotificacionUsuario.obtenerNotificacionesNoLeidas(request));
        // model.put("path", request.getSession().getServletContext().getRealPath("/img/pacientes/"));
        return new ModelAndView("solicitud-derivaciones/ver-solicitud-derivacion",model);
    }

    @RequestMapping(path="/agregar-solicitud-derivacion", method = RequestMethod.POST)
    public ModelAndView agregarSolicitudDerivacion(RedirectAttributes attributes,
                                                   @RequestParam("idDerivacion") Long idDerivacion,
                                                    @RequestParam("centroMedico") Long idCentroMedico,
                                                   @RequestParam("descripcion") String descripcion,
                                                   HttpServletRequest request
    ) throws Exception {

        servicioSolicitudDerivacion.guardarSolicitudDerivacion(idDerivacion, idCentroMedico, descripcion, request);
        attributes.addFlashAttribute("message","Se creo la solicitud derivación correctamente");
        return new ModelAndView("redirect:/listado-derivacion");
    }

    @RequestMapping(path = "aceptarSolicitud/{idSolicitud}", method = RequestMethod.POST)
    public ModelAndView aceptarSolicitud(@PathVariable Long idSolicitud, @RequestParam("mensaje")String mensaje,HttpServletRequest request){
        servicioSolicitudDerivacion.aceptarSolicitudDerivacion(idSolicitud, request, mensaje);
    return new ModelAndView("redirect:/solicitudes-derivaciones");
    }

    @RequestMapping(path = "rechazarSolicitud/{idSolicitud}", method = RequestMethod.POST)
    public ModelAndView rechazarSolicitud(@PathVariable Long idSolicitud, @RequestParam("mensaje")String mensaje, HttpServletRequest request){
        servicioSolicitudDerivacion.rechazarSolicitudDerivacion(idSolicitud, request, mensaje);
        return new ModelAndView("redirect:/solicitudes-derivaciones");
    }
    @RequestMapping(path = "verSolicitudes/{idDerivacion}",method = RequestMethod.GET)
    public ModelAndView verSolicitudDerivacionPorDerivacion(@PathVariable Long idDerivacion,HttpServletRequest request){
        ModelMap model = new ModelMap();
        List<SolicitudDerivacion> lista= servicioSolicitudDerivacion.obtenerSolicitudesDeDerivacionPorDerivacion(idDerivacion);
        model.put("rol",request.getSession().getAttribute("ROL"));
        model.put("listaSolicitudesDerivaciones",lista);
        model.put("cantNotificacion",servicioNotificacionUsuario.obtenerNotificacionesNoLeidas(request));
        return new ModelAndView("/solicitud-derivaciones/solicitud-derivaciones", model);

    }

    @RequestMapping(path = "adjuntar-archivo-solicitud/{idSolicitud}", method = RequestMethod.POST)
    public ModelAndView adjuntarArchivo(@RequestParam("adjunto") MultipartFile adjunto, @PathVariable Long idSolicitud,
                                        HttpServletRequest request, @RequestParam("titulo") String titulo) throws Exception {
        SolicitudDerivacion solicitudDerivacion = servicioSolicitudDerivacion.obtenerSolicitudDerivacionPorId(idSolicitud);
        if(solicitudDerivacion != null){
            String path = request.getSession().getServletContext().getRealPath("/img/adjuntos/");
            servicioAdjunto.guardarImagen(adjunto,path,solicitudDerivacion, titulo);
        }
        return new ModelAndView("redirect:/ver-solicitud-derivacion/"+solicitudDerivacion.getId());
    }

}